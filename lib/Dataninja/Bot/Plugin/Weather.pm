package Dataninja::Bot::Plugin::Weather;
use Moose;
use Weather::Underground;
use String::Util qw/crunch/;
extends 'Dataninja::Bot::Plugin::Base';

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

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    my $weather_code = sub {
        my $command_args = shift;
        my $place = crunch $command_args;
        my ($weather_data, $get_weather);

        my $areas = Dataninja::Model::AreaCollection->new;
        $areas->limit(column => 'nick', value => $self->nick);
        if ($place) {
            my $area;
            if ($areas->count > 0) {
                $area = $areas->next;
                $area->set_location($place);
            }
            else {
                $area = Dataninja::Model::Area->new;
                $area->create(
                    location => $place,
                    nick     => $self->nick,
                    network  => $self->network,
                );
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
            }
            return "I am so buggy! FIX ME" unless $place;
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

        return "I am so buggy! FIX ME" unless $get_weather;

        return _weather_output($get_weather, $place);
    };

    $self->command(weather => $weather_code);
    $self->command(w       => $weather_code);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

