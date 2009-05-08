package Botbot;
use Moose;
use MooseX::NonMoose;
extends 'App::Dataninja::Bot';

before 'run' => sub {
    my $self = shift;
    print "Thanks for using Botbot!\n";
    print "\nWARNING WARNING WARNING:\n"
        . "Botbot will not work until the next MooseX::NonMoose release!\n\n";
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

