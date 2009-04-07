package Dataninja::Bot::Plugin::Weather;
use Moose;
use Weather::Underground;
use String::Util qw/crunch/;
extends 'Dataninja::Bot::Plugin::Base';

sub get_weather  {
    my $place = shift;
    my $weather_data = Weather::Underground->new(place => $place)
        or return "$!";
    return $weather_data->get_weather;
}

sub weather_output {
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
        my $nick_being_called = (my $place) = crunch $command_args;
        my ($weather_data, $get_weather);

        my $areas = Dataninja::Model::AreaCollection->new;
        $areas->limit(column => 'nick', value => ($nick_being_called || $self->nick));
        if ($areas->count > 0) {
            my $area = $areas->next;
            my $new_place = $area->location;
            my $get_weather = get_weather($new_place);
            return weather_output($get_weather, $new_place);
        }
        elsif (!$place) {
            return "you have no location set!";
        }

        if ($get_weather = get_weather($place)) {
            my $areas = Dataninja::Model::AreaCollection->new;
            $areas->limit(column => 'nick', value => $self->nick);
            if ($areas->count > 0) {
                my $nick_area = $areas->next;
                $nick_area->set_location($place);
            }
            else {
                my $new_area = Dataninja::Model::Area->new;
                my ($ok, $error) = $new_area->create(
                    nick => $self->nick,
                    location => $place,
                );
                return $error unless $ok;
            }
            return weather_output(get_weather($place), $place);
        }
        else {
            return "invalid area";
        }
    };

    $self->command(weather => $weather_code);
    $self->command(w       => $weather_code);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

