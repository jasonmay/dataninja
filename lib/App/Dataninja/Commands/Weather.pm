package App::Dataninja::Commands::Weather;
use App::Dataninja::Commands::OO;
use URI::Escape;
use LWP::Simple;
use XML::Simple;

use String::Util qw/crunch/;

=head1 NAME

App::Dataninja::Commands::Weather - get current weather information from Weather Underground

=head1 COMMANDS

=over

=item * weather B<[nick|location]>

The way you use this command is like so:

 < jasonmay> !weather
 < macbookDN> you have no location set!
 < jasonmay> !weather 17313
 < dataninja> weather for "17313" - temp: 53.1F (11.7C). humidity: 100%. 
              wind: 0.0mph. conditions: Light Rain.
 < jasonmay> !weather
 < dataninja> weather for "17313" - temp: 53.1F (11.7C). humidity: 100%. 
              wind: 0.0mph. conditions: Light Rain.
 < otherguy> !weather 90210
 < dataninja> weather for "90210" - temp: 65.3F (18.5C). humidity: 68%. 
              wind: 0.0mph. conditions: Clear.
 < otherguy> !weather
 < dataninja> weather for "90210" - temp: 65.3F (18.5C). humidity: 68%. 
              wind: 0.0mph. conditions: Clear.
 < otherguy> !weather jasonmay
 < dataninja> weather for "17313" - temp: 53.1F (11.7C). humidity: 100%. 
              wind: 0.0mph. conditions: Light Rain.


=item * w B<[nick|location]>

This is an alias for B<weather>.

=back

=cut


sub get_weather  {
    my $place = shift;

    my $query = uri_escape($place);

    my $xml     = get("http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=$query");
    my $xmldata = XMLin($xml);

    return $xmldata;
}

sub weather_output {
    my $get_weather = shift;
    my $place = shift;
    my $target_weather = $get_weather;
    return
    sprintf(
        'weather for "%s" - temp: %sF (%sC). humidity: %s%%. wind: %smph. conditions: %s.',
        $place,
        $target_weather->{temp_f},
        $target_weather->{temp_c},
        $target_weather->{relative_humidity},
        $target_weather->{wind_mph},
        $target_weather->{weather}
    );
}

command ['w', 'weather'] => sub {
    my $match = shift;
    my $command_args = shift;
    my $incoming     = shift;
    my $profile      = shift;
    my $storage       = shift;
    my $place;
    my $nick_being_called = $place = crunch $command_args;
    my ($weather_data, $get_weather);

    my $area =
        $storage->resultset('Area')
        ->find({
            nick => ($nick_being_called || lc($incoming->sender->name))
        },
        {rows => 1},
    );

    if (defined $area) {
        my $new_place = $area->location;
        my $get_weather = get_weather($new_place);
        return weather_output($get_weather, $new_place);
    }
    elsif (!$place) {
        return "you have no location set!";
    }

    if ($get_weather = get_weather($place)) {
        my $nick_area = $storage->resultset('Area')->find(
            {nick => $incoming->sender->name},
            {rows => 1},
        );
        if (defined $nick_area) {
            $nick_area->update({location => $place});
        }
        else {
            $storage->resultset('Area')
                ->create({
                    nick     => $incoming->sender->name,
                    location => $place,
                    network  => $profile,
                });
        }
        return weather_output(get_weather($place), $place);
    }
    else {
        return "invalid area";
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

