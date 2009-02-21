#!/usr/bin/env perl
use strict;
use warnings;

use Jifty::Everything; BEGIN{Jifty->new}
use DDS;

my $msgs = Dataninja::Model::MessageCollection->new;
$msgs->limit;
$msgs->order_by(column => 'moment', order => 'desc');

$msgs->rows_per_page(@ARGV ? $ARGV[0] : 10);

for (reverse @$msgs) {
   printf("%s [%s] < %s> %s\n", $_->moment, $_->network, $_->nick->name, $_->message)
}
