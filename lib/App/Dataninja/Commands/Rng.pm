#!/usr/bin/env perl
package App::Dataninja::Commands::Rng;
use App::Dataninja::Commands::OO;
use namespace::autoclean;

command rng => sub {
    my $match = shift;
            my $args = shift;
            my @choices = split ' ', $args;

            return $choices[rand @choices];
};

__PACKAGE__->meta->make_immutable;

1;

