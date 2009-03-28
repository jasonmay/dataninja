package Dataninja::Bot::Plugin::Colors;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        colors => sub {
            return join q{ },
            map {
                "\e[0;3${_}m${_}\e[1;3${_}m${_}\e[0m"
            } (0 .. 7);
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

