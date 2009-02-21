#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Weather;
use base 'Dataninja::Bot::Command';
use Weather::Underground;
use String::Util qw/crunch/;

sub pattern { qr|^#w(?:eather)?\b(.*)?$| }

sub _get_weather  {
    my $place = shift;
    my $weather_data = Weather::Underground->new(place => $place)
        or return "$!";
    return $weather_data->get_weather;
}

sub _weather_output {
    my $get_weather = shift;
    my $place = shift;
    my $target_weather = $get_weather->[0];
    return
        sprintf(
            'weather for "%s" - temp: %sF (%sC). humidity: %s%%. wind: %smph. conditions: %s.',
            $place,
            $target_weather->{temperature_fahrenheit},
            $target_weather->{temperature_celsius},
            $target_weather->{humidity},
            $target_weather->{wind_milesperhour},
            $target_weather->{conditions}
        );
}

sub run {
    my $args = shift;
    my $place = crunch $1;
    my ($weather_data, $get_weather);

    my $areas = Dataninja::Model::AreaCollection->new;
    $areas->limit(column => 'nick', value => $args->{who});
    if ($place) {
        my $area;
        if ($areas->count > 0) {
            $area = $areas->next;
            $area->set_location($place);
            warn "$args->{who} has an area yay";
        }
        else {
            $area = Dataninja::Model::Area->new;
            warn "$place, $args->{who}, $args->{network}";
            $area->create(
                location => $place,
                nick     => $args->{who},
                network  => $args->{network}
            );
            warn "$args->{who} is making a new area";
        }
      
        unless ($get_weather = _get_weather($place)) {
            my $weather_from_nick = Dataninja::Model::AreaCollection->new;
            # $place is a nick in this case
            $weather_from_nick->limit(column => 'nick', value => $place);
            if ($weather_from_nick->count > 0) {
                my $nick_area = $weather_from_nick->next;
                return "Invalid area" unless $nick_area;
                my $place = $nick_area->location;
                $weather_data = Weather::Underground->new(place => $place);
                $get_weather = $weather_data->get_weather;
                return _weather_output($get_weather, $place) if $get_weather;
            }
            else {
                return "Invalid area";
            }
        }
    }
    else {
        if ($areas->count > 0) {
            my $area = $areas->next;
            $place = $area->location;
            warn "$args->{nick} is retrieving an area from the db";
        }
        return "bawwwwww!" unless $place;
    }

    $get_weather = _get_weather($place);
    unless ($get_weather) {
        my $weather_from_nick = Dataninja::Model::AreaCollection->new;
        # $place is a nick in this case
        $weather_from_nick->limit(column => 'nick', value => $place);
        if ($weather_from_nick) {
            my $nick_area = $weather_from_nick->next;
            return "Invalid area" unless $nick_area;
            $place = $nick_area->location;
            $get_weather = _get_weather($place);
            return _weather_output($get_weather, $place) if $get_weather;
        }
        else {
            return "Invalid area";
        }
    }

    return "bawwwwww!" unless $get_weather;

    return _weather_output($get_weather, $place);
}

1;
