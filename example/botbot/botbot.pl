#!/usr/bin/env perl
use strict;
use warnings;

use Botbot;
use App::Dataninja::Config;
use App::Dataninja::Schema;
use DBICx::Deploy;

my $dsn = 'DBI:SQLite:dbname=botbot.sqlite';
DBICx::Deploy->deploy('App::Dataninja::Schema' => $dsn)
    unless -e 'botbot.sqlite';

my $botbot = Botbot->new({
    config => App::Dataninja::Config->new(
        default_config => 'config.yml',
        site_config    => 'site_config.yml',
        secret_config  => 'secret_config.yml',
    ),
    schema => App::Dataninja::Schema->connect($dsn),
    assigned_network => 'dev',
});

$botbot->search_path(add => 'Botbot::Plugin');
$botbot->run;
