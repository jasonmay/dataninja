#!/usr/bin/env perl
use strict;
use warnings;
use Lexical::Persistence;
use Data::Dump::Streamer;
use Safe;

my $lp = Lexical::Persistence->new;

my $compartment = Safe->new;
$compartment->permit( qw/:base_core :base_mem :base_math require caller entereval pack unpack sort fileno tied/ );

chdir;
my $OUT = '.fifo.in';
my $IN = '.fifo.out';

while (1) {
    unless (-p $OUT) {
        unlink $OUT;
        require POSIX;
        POSIX::mkfifo($OUT, 0700)
            or die "could not create fifo :)";
    }

    unless (-p $IN) {
        unlink $IN;
        require POSIX;
        POSIX::mkfifo($IN, 0700)
            or die "could not create fifo :(";
    }

    open (IN, "< $IN") || die "could not open fifo for writing";
    my $line = <IN>; chomp $line;
    close IN;

    open (OUT, "> $OUT") || die "could not open fifo for writing";
    my @result;
    my $code = $compartment->reval("sub { no strict;\n$line\n }"); # eval for syntax errors
    if ($@) {
        print OUT $@;
    }
    else {
        local $SIG{ALRM} = sub {
            print OUT "out of time!\n";
            die 'alarm_clock'
        };

        eval { # eval for alarm timeout
            alarm 10;
            @result = $lp->call($code);
            alarm 0;

            if ($@) {
                print OUT $@;
            }
            else { 
                if (!@result) {
                    print OUT "undef";
                }
                for (@result) {
                    if (my $ref = ref) {
                        $_ = Dump($_)->Out();
                        s/\s+/ /g;
                        s/^.+?= //;
                        s/;\s*$// unless $ref eq 'CODE';
                        s/^\[ /[/,  s/ \]$/]/ if $ref eq 'ARRAY';
                        s/^\{ /{/,  s/ \}$/}/ if $ref eq 'HASH';
                    }
                    else  {
                        $_ = qq{'$_'};
                    }
                    s/\r/ /g;
                    s/\n/; /g;
                }
                print OUT join(q{, } => @result), "\n";
            }
        };
    }
    $@ = q{} if $@; # eval isn't resetting $@ for whatever reason
    close OUT;
    sleep 2;
}
