package Dataninja::Bot::Plugin::Botsnack;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        botsnack => sub { "sweet, thanks! :)" }
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

