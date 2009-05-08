package Botbot;
use Moose;
extends 'App::Dataninja::Bot';

before 'run' => sub { print "Thanks for using Botbot!\n" };

__PACKAGE__->meta->make_immutable;
no Moose;

1;

