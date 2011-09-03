#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use App::Dataninja::Cmd;

my $d = App::Dataninja::Cmd->new_with_options(@ARGV);

$d->run;
