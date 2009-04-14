#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Dataninja::Bot::Interface;

my $network = shift;
my $bot = Dataninja::Bot::Interface->new($network);
$bot->_plugin_app_ns(['Dataninja::Bot::Plugin']);
$bot->load_plugin('Foobar');
$bot->run;
