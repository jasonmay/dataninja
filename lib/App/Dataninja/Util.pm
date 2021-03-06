#!/usr/bin/env perl
package App::Dataninja::Util;
use strict;
use warnings;
use DateTime;
use IM::Engine::Outgoing::IRC::Channel;
use Class::Load;

sub tick {
    my $block = shift;

    my $storage = $block->param('storage');
    my $reminder = $storage->first_due_reminder;

    if ($reminder) {
        my $format_module = "DateTime::Format::Pg";
        Class::Load::load_class($format_module);
        warn $reminder->made;
        my $made_dt = $format_module->parse_datetime($reminder->made);

        # show only if reminder was made more than a month ago
        my $set_message = DateTime->compare(
            $made_dt->add(days => 10),
            DateTime->now
        ) < 0 ? sprintf("(set %s) ", $made_dt->ymd) : '';

        record_and_send_message(
            $block->param('storage'), $block->param('engine'),
            channel => $reminder->channel,
            message => sprintf(
                '%s%s: %s',
                $set_message,
                $reminder->remindee,
                $reminder->description,
            )
        );

        $reminder->update({reminded => 1});
    }

    my $interjection = $storage->first_interjection;

    if ($interjection) {
        record_and_send_message(
            $block->param('storage'), $block->param('engine'),
            channel => $interjection->channel,
            message => $interjection->message,
            #emotion => $interjection->emotion,
        );

        $interjection->update({interjected => 1});
    }
}

sub record_and_send_message {
    my $storage = shift;
    my $engine = shift;
    my %args = @_;

    $storage->log_response(
        channel  => $args{channel},
        response => $args{message},
    );

    send_message(
        $engine,
        channel => $args{channel},
        message => $args{message},
    );
}

sub send_message {
    my $engine = shift;
    my %args   = @_;

    my $outgoing = IM::Engine::Outgoing::IRC::Channel->new(
        channel => $args{channel},
        message => $args{message},
    );

    $engine->send_message($outgoing);
}

sub send_private_message {
    my $engine = shift;
    my %args   = @_;

    my $outgoing = IM::Engine::Outgoing::IRC::Channel->new(
        recipient => $args{recipient},
        message   => $args{message},
    );

    $engine->send_message($outgoing);
}

1;
