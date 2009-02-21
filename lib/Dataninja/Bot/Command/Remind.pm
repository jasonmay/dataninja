#!/usr/bin/env perl
use strict;
use warnings;
use Time::ParseDate;
use DateTime;
package Dataninja::Bot::Command::Remind;
use base 'Dataninja::Bot::Command';

=head1 DESCRIPTION

Reminds a user to blah blah TODO

=cut

sub pattern { qr/^(?:dataninja:\s+|#)remind\s+(\S+)\s+(.+)\s+(?:in|at|on)\s+(.+)/ }

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
    $nick = $args->{'who'} if $nick eq 'me';
    my $reminder = Dataninja::Model::Reminder->new;

    my $when = Time::ParseDate::parsedate($time, PREFER_FUTURE => 1);
    return "it's too late for that :(" if $when < time();

    my $dt = DateTime->from_epoch(epoch => $when);

    my ($ok, $error) = $reminder->create(
            remindee    => $nick,
            description => $desc,
            channel     => $args->{'channel'},
            network     => $args->{'network'},
            maker       => $args->{'who'},
            moment      => $dt
            );

    return $error unless $ok;
    $dt->set_time_zone('America/New_York');
    return sprintf('will remind at: %s %s %s [id: %s]', $dt->ymd, $dt->hms, $dt->time_zone->name, $reminder->id);
}

sub usage { "#remind <nick|me> <description> (in|at) <when>" }
sub current_user_can { 1 }

1;
