#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Util::Markov;
use DBI;
use List::MoreUtils qw/uniq true any firstidx/;

open DBPW, "$ENV{HOME}/.dbpass";
my $dbpass = <DBPW>;
($dbpass)  = $dbpass =~ /(.+)/;
close DBPW;

my $dbh;
$dbh = DBI->connect('dbi:Pg:dbname=dataninja', 'jasonmay', $dbpass) 
	or die "DB problem.\n";

sub _construct_placeholders {
    my $number = shift;
    my @chain = @_;
    my $regex_start = "    E'(^|\\\\s+)'   || ";
    my $regex_delim = " || E'\\\\s+'       || ";
    my $regex_end   = " || E'(\\\\s+|\$)'     ";
    return $regex_start . join($regex_delim, ('?') x $number) . $regex_end;
}

sub generate {
    my $input = shift;
    my $THRESHOLD = 5;
    my @chain = (split ' ', $input);
    my $link = @chain;
    my $threshold = 0;
    my $begin = '';
    while ($threshold++ < $THRESHOLD) {

# grab random row {{{
    my $query_regex = @chain ? _construct_placeholders($link) : "''";

    my $random_val_query =
        "select random()*(select count(*)-1 from messages ".
        "where message ~ ($query_regex) and nick != ?)::integer";

    my @args = map {quotemeta} (@chain ? reverse map { $chain[-$_] } (1 .. $link) : ());
    my $rand = sql_oneval($random_val_query, @args, 'dataninja');
    if (!$rand) {
        warn "!\$rand";
        last;
    }
    $rand = int $rand;
    my $random_row_query =
        "select message from messages where message ~ ($query_regex) ".
        "and nick != ?" . 
        "limit 1 offset $rand";

    my $row = sql_firstrow($random_row_query, @args, 'dataninja');

    if (!$row) {
        warn "!\$row";
#return "markov FAIL (until jasonmay fixes this)";
        last;
    }
# }}}

    my @words = split ' ', $row->{'message'};

# canonicalize words {{{
    my @c_words = map { canonicalize_word($_) } @words;
# }}} 
# assign $idx and next if no pieces are found or pieces do not fit {{{
# this checks if @chain has any words in common with @c_words
    next unless any {
        my $word = $_;
        any {
            $_ eq $word
        } map {
            canonicalize_word($chain[-$_])
        } (1 .. $link)
    } @c_words;

    my $idx = check_sequence(
            [ @c_words ],
            [ reverse map {
            canonicalize_word($chain[-$_])
            } (1 .. $link) ]
            );

    next if $idx > $#c_words-$link;
    $begin = join ' ', @c_words[0 .. $idx-1] if scalar(@chain) == $link;
# }}}

    $threshold = 0;
    push @chain, $words[$idx + $link];

    if (@chain > 50) {
        warn "\@chain > 50";
        last;
    }
    print "[ @chain ]\n";
    }
    warn "Exceeded threshold" if $threshold >= $THRESHOLD;
    return "$begin " . join(' ', @chain);
}

sub sql_firstrow {
    my $query = shift;
    my @args = @_;
    my $sth   = $dbh->prepare($query) || die "$!\n";
    $sth->execute(@args);
    $sth->fetchrow_hashref;
}

sub sql_oneval {
    my $query = shift;
    my @args = @_;
    my $sth   = $dbh->prepare($query) || die "$!\n";
    $sth->execute(@args);
    ($sth->fetchrow_array || (undef))[0];
}

sub canonicalize_word {
    my $word = shift;
#    $word    =~ s/\W//;
#    $word    = lc $word;
    $word;
}

sub check_sequence {
    my $words = shift;
    my $seq = shift;

    my $i = 0;
    foreach my $outer (
            map {
            join ' ', @$words[$_ .. $_ + @$seq - 1]
            } (0 .. @$words - @$seq)
            ) {
#        warn $outer;
#        warn join(' ', @$seq);
#        warn "--------------";
        return $i if join(' ', @$seq) eq $outer;
        ++$i;
    }

    -1;
}

1;
