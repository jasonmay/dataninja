#!/usr/bin/env perl
package Dataninja::Bot::Command::Blank;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';

sub pattern { qr{^#hey} }
sub run { "foo" }


1;

