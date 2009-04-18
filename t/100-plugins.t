#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Dataninja::Schema;
use DBD::Mock;
use DateTime;
use lib 'lib';

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
