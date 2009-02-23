#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Cancel;
use Time::ParseDate;
use DateTime;
use Dataninja::Model::Reminder;

=head1 DESCRIPTION

Reminds a user to blah blah TODO

=cut

sub pattern { qr/#cancel\s+(\d+)/ }

sub run {
    my $args = shift;
    my $requested_id = $1;

    my $reminders = Dataninja::Model::ReminderCollection->new;
    $reminders->limit(column => 'id', value => $requested_id);

    my $reminder = $reminders->first;

    if (defined $reminder) {
        return "that reminder wasn't for you!" if $args->{who} ne $reminder->maker;
        return "you don't need to worry about that"
            if $reminder->reminded or $reminder->canceled;
        $reminder->set_canceled(1);
        return "canceled";
    }

# catchall
    return "could not find a reminder with that ID";
}

1;
