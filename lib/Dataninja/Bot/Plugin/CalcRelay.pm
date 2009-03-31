package Dataninja::Bot::Plugin::CalcRelay;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        c => sub {
            my $command_args = shift;
            return "!c $command_args";
        }
    );
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

