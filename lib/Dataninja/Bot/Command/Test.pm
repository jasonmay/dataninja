#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Test;
use base 'Dataninja::Bot::Command';
use Dataninja::Model::Message;

sub pattern { qr{^#test} }
sub run { "Pong! Oh wait" }

1;
