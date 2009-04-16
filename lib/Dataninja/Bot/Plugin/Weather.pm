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
        my $place;
        my $nick_being_called = $place = crunch $command_args;
        my ($weather_data, $get_weather);

        my $area =
            $self->rs('Area')
            ->search( {nick => ($nick_being_called || $self->nick)} )->single;
        if (defined $area) {
            my $new_place = $area->location;
            my $get_weather = get_weather($new_place);
            return weather_output($get_weather, $new_place);
        }
        elsif (!$place) {
            return "you have no location set!";
        }

        if ($get_weather = get_weather($place)) {
            my $nick_area = $self-rs('Area')->search(
                {nick => $self->nick}
            )->single;
            if (defined $nick_area) {
                $nick_area->update({location => $place});
            }
            else {
                $self->rs('Area')
                    ->create({ nick => $self->nick, location => $place, });
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

