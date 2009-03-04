#!/usr/bin/env perl
use strict;
use warnings;
use DateTime;
use DateTime::Format::Natural;
package Dataninja::Bot::Command::Remind;
use base 'Dataninja::Bot::Command';

=head1 DESCRIPTION

Reminds a user to blah blah TODO

=cut

sub pattern { qr/^(?:dataninja:\s+|#)remind\s+(\S+)\s+(.+)\s+>\s+(.+)/ }

sub run {
    my $args = shift;
    my ($nick, $desc, $time) = ($1, $2, $3);
    my %numbers = (
        one       => 1,
        two       => 2,
        three     => 3,
        four      => 4,
        five      => 5,
        six       => 6,
        seven     => 7,
        eight     => 8,
        nine      => 9,
        ten       => 10,
        eleven    => 11,
        twelve    => 12,
        thirteen  => 13,
        fourteen  => 14,
        fifteen   => 15,
        sixteen   => 16,
        seventeen => 17,
        eighteen  => 18,
        nineteen  => 19,
        twenty    => 20,
        thirty    => 30,
        fourty    => 40,
        fifty     => 50,
        sixty     => 60,
        seventy   => 70,
        eighty    => 80,
        ninty     => 90,
        ninety    => 90,
    );

    foreach my $word (keys %numbers) {
        $time =~ s/\b$word\b/$numbers{$word}/ge;
        $time =~ s/\ba\s+few\b/3/ge;
        $time =~ s/\bseveral\b/8/ge;
        $time =~ s/\ban?\b/1/ge;
    }

#    $time .= ' from now' if ($prep eq 'in');

    $nick = $args->{'who'} if $nick eq 'me';
    my $reminder = Dataninja::Model::Reminder->new;

    my $parser = DateTime::Format::Natural->new(time_zone => 'America/New_York', prefer_future => 1);
    my $when_to_remind = $parser->parse_datetime($time);
    $when_to_remind->set_time_zone('UTC');

    if (!$parser->success) {
        return "huh? see http://search.cpan.org/~schubiger/DateTime-Format-Natural/lib/DateTime/Format/Natural/Lang/EN.pm";
    }

    return "must authenticate yourself as Doc Brown to do that"
        if DateTime->compare($when_to_remind->clone(time_zone => 'America/New_York'), DateTime->now) < 0;

    my ($ok, $error) = $reminder->create(
            remindee    => $nick,
            description => $desc,
            channel     => $args->{'channel'},
            network     => $args->{'network'},
            maker       => $args->{'who'},
            moment      => $when_to_remind
            );

    return $error unless $ok;
    $when_to_remind->set_time_zone('America/New_York');
    return sprintf('will remind at: %s %s %s [id: %s]',
        $when_to_remind->ymd,
        $when_to_remind->hms,
        $when_to_remind->time_zone->name,
        $reminder->id);
}

sub usage { "#remind <nick|me> <description> (in|at) <when>" }

1;
