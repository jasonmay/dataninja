#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use App::Dataninja::Container;

my %params;
$params{profile} = $ARGV[0] if @ARGV;
my $c = App::Dataninja::Container->new(%params);

my $app = $c->fetch('app')->get;

$app->run;
