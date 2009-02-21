#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Dataninja::Bot::Interface;

die "no network specified" unless @ARGV;
my $bot = Dataninja::Bot::Interface->new(shift);
$bot->run;
