#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Daysuntil;
use base 'Dataninja::Bot::Command';
use DateTime::Format::Natural;

sub pattern { qr|^#daysuntil\s+(.+)$| }

sub run {
    my $parser = DateTime::Format::Natural->new;
    my $dt = $parser->parse_datetime($1);
    my $now = DateTime->now;

    my $seconds_diff = $dt->epoch - $now->epoch;
    return "it's too late for that :(" if $seconds_diff < 0;

    my $days_diff = int($seconds_diff/86400);

    return "$days_diff days!";
}

1;
