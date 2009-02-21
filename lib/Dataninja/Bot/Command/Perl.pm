#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Perl;
use base 'Dataninja::Bot::Command';

sub pattern { qr|^#perl\s+(.+)$| }

sub run {
    my $code = $1;
    return undef unless $code;
    open OUT, "> $ENV{HOME}/.fifo.out";
    print OUT "$code\n";
    close OUT;

    open IN, "< $ENV{HOME}/.fifo.in";
    my $result = <IN>;
    close IN;

    return $result;
}

1;
