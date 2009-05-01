package Dataninja::Bot::Plugin::Echo;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        echo => sub {
            my $command_args = shift;
            return $command_args;
        }
    )
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

