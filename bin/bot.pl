#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Dataninja::Bot::Interface;
use Dataninja::Config;
use Dataninja::Schema;

my $network = shift;

my $config = Dataninja::Config->new;
my $database_config = $config->main->{database};
my $schema = Dataninja::Schema->connect(
    "dbi:Pg:dbname=$database_config->{name}",
    $database_config->{user},
    $database_config->{password}
);

my $bot = Dataninja::Bot::Interface->new($config, $network, $schema);
$bot->_plugin_app_ns(['Dataninja::Bot::Plugin']);
#$bot->load_plugin('Foobar');
$bot->run;
