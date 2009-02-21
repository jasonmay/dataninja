#!/usr/bin/env perl
package Dataninja::Bot::Command::Drop;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';

sub pattern { qr|^#drop\b| }
sub run { "foo" }

1;

