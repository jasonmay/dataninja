#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Weeksuntil;
use base 'Dataninja::Bot::Command';
use DateTime::Format::Natural;
use DateTime::Format::Duration;

sub pattern { qr|^#weeksuntil\s+(.+)$| }

sub run {
    my $parser = DateTime::Format::Natural->new;
    my $dt = $parser->parse_datetime($1);
    my $now = DateTime->now;

    my $diff = $dt->subtract_datetime($now);
    my $format_week = DateTime::Format::Duration->new(pattern => '%W');
    return sprintf('%s weeks!', int($format_week->format_duration($diff)));
}

1;
