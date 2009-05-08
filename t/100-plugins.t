#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use App::Dataninja::Schema;
use DBD::Mock;
use DateTime;
use lib 'lib';
use DBIx::Class::Row;

my @schema_classes = qw/Area Interjection Message Nick Person Reminder/;
plan tests => 3;

use_ok 'App::Dataninja::Bot::Plugin';

my $plugin = App::Dataninja::Bot::Plugin->new(
    message_data => DBIx::Class::Row->new,
    schema => App::Dataninja::Schema->connect('dbd:Mock:'),
);

#can_ok($plugin, 'rs');
can_ok($plugin, 'command');
can_ok($plugin, 'command_setup');

