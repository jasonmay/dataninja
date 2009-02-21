#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Conditions;
use base 'Dataninja::Bot::Command';
use Weather::Underground;

sub pattern { qr|^#c(?:onditions)?\s+(.+)$| }

sub run {
    my $place = $1;
    my $weather_data = Weather::Underground->new(place => $place)
        or return $!;
    my $get_weather = $weather_data->get_weather;
    return "Invalid area" unless $get_weather;
    my $target_weather = $get_weather->[0];

    return $target_weather->{conditions};
}

1;
