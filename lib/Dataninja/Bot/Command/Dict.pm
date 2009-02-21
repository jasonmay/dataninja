#!/usr/bin/env perl
package Dataninja::Bot::Command::Dict;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';

sub pattern { qr|#dict\b| }
sub run { "foo" }

1;

