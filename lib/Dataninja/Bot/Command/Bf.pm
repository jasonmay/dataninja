#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Bf;
use base 'Dataninja::Bot::Command';

sub pattern { qr|^#bf\s+(.+)$| }

sub run {
    $_ = $1;
    s/(.)(\d+)/$1 x $2/ge;
    return "~bf $_";
}

1;

