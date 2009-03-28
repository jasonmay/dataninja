package Dataninja::Bot::Plugin::Daysuntil;
use Moose;
use DateTime::Format::Natural;
extends 'Dataninja::Bot::Plugin::Base';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        daysuntil => sub {
            my $command_args = shift;
            my $parser = DateTime::Format::Natural->new;
            my $dt = $parser->parse_datetime($command_args);
            my $now = DateTime->now;

            my $seconds_diff = $dt->epoch - $now->epoch;
            return "it's too late for that :(" if $seconds_diff < 0;

            my $days_diff = int($seconds_diff/86400);

            return "$days_diff days!";
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

