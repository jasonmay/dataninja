#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Botsnack;
use base 'Dataninja::Bot::Command';

sub pattern { qr|^#botsnack\b| }

sub run {
    return "sweet, thanks! :)";
}

1;

