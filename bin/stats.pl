#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use App::Dataninja::Schema;
use DDS;

my $schema = App::Dataninja::Schema->connect_with_defaults;
my $msg_rs = $schema->resultset('Message');
my $stats_rs = $schema->resultset('NickStats');

my $nick_rs = $msg_rs->search({nick => 'jasonmay', stats_updated => 0});

my $rs = $msg_rs->search(
    {
        nick          => 'jasonmay',
        stats_updated => 0,
    }
);

while (my $nick_row = $rs->next) {
    my $dt = $nick_row->moment;
    my %stats_mapping = (
        (map { $_ => $nick_row->$_ } qw/network channel nick/),
        (map { $_ => $dt->$_  } qw/year month day dow hour/),
    );

    if (!$stats_rs->search(\%stats_mapping)->count) {
        $stats_rs->create({%stats_mapping});
    }
    else {
        my $row = $stats_rs->search(\%stats_mapping)->first;
        $row->update({%stats_mapping, quantity => $row->quantity + 1}) if $row;
    }

    $nick_row->update({stats_updated => 1});
}
