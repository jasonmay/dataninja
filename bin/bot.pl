#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Dataninja::Bot::Interface;

die "no network specified" unless @ARGV;
my $bot = Dataninja::Bot::Interface->new(shift);
$bot->_plugin_app_ns(['Dataninja::Bot::Plugin']);
$bot->load_plugin('Foobar');
$bot->run;
