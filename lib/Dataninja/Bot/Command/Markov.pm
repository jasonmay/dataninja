#!/usr/bin/env perl
package Dataninja::Bot::Command::Markov;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';
use Dataninja::Bot::Util::Markov;

sub pattern { qr|^#m(?:arkov)?\s+(.+)| }
sub run {
    my $markov;
    eval { $markov = Dataninja::Bot::Util::Markov::generate($1) };
    return $@ if $@;
    return $markov;
}

1;

