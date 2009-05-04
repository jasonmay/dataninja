#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Dataninja::Schema;
use DBD::Mock;
use DateTime;
use lib 'lib';
use DBIx::Class::Row;

my @schema_classes = qw/Area Interjection Message Nick Person Reminder/;
plan tests => 4 + @schema_classes;

use_ok 'Dataninja::Bot::Plugin';

my $plugin = Dataninja::Bot::Plugin->new(
    message_data => DBIx::Class::Row->new,
    schema => Dataninja::Schema->connect('dbd:Mock:'),
);

can_ok($plugin, 'rs');
can_ok($plugin, 'command');
can_ok($plugin, 'command_setup');

is($plugin->rs($_)->result_class, "Dataninja::Schema::$_") for @schema_classes;
