#!/usr/bin/env perl
package App::Dataninja::Bot::Plugin::Rng;
use Moose;
use namespace::autoclean;
extends 'App::Dataninja::Bot::Plugin';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        rng => sub {
            my $args = shift;
            my @choices = split ' ', $args;

            return $choices[rand @choices];
        }
    );
};

__PACKAGE__->meta->make_immutable;

1;

