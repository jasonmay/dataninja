#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use lib "$ENV{HOME}/repos/git/dataninja/lib";
use Botbot;
use Dataninja::Config;
use Dataninja::Schema;
use DBICx::Deploy;

my $dsn = 'DBI:SQLite:dbname=botbot.sqlite';
DBICx::Deploy->deploy('Dataninja::Schema' => $dsn);

my $botbot = Botbot->new(
    Dataninja::Config->new(
        default_config => 'config.yml',
        site_config    => 'site_config.yml',
        secret_config  => 'secret_config.yml',
    ),
    'dev',
    Dataninja::Schema->connect($dsn),
);

$botbot->search_path(add => 'Botbot::Plugin');
$botbot->run;
