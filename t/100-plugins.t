#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Dataninja::Schema;
use DBD::Mock;
use DateTime;
use lib 'lib';

my @schema_classes = qw/Area Interjection Message Nick Person Reminder/;
plan tests => 4 + @schema_classes;

use_ok 'Dataninja::Bot::Plugin::Base';

my $plugin = Dataninja::Bot::Plugin::Base->new(
    network => '',
    nick => '',
    channel => '',
    message => '',
    moment => DateTime->now,
    schema => Dataninja::Schema->connect('dbd:Mock:'),
);

can_ok($plugin, 'rs');
can_ok($plugin, 'command');
can_ok($plugin, 'command_setup');

is($plugin->rs($_)->result_class, "Dataninja::Schema::$_") for @schema_classes;
