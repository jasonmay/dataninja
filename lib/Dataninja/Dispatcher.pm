#!/usr/bin/env perl
package Dataninja::Dispatcher;
use strict;
use warnings;
use Jifty::Dispatcher -base;

# WHAAAAAAA
on qr{/stats (?: / (\w+) (?: / (\w+) (?: / (\w+) )? )? )? }x => run {
    set nick    => $3 if $3;
    set channel => "#$2" if $2;
    set network  => $1 if $1;
    show 'stats';
};

on qr{/chat} => run {
    my $p = 'ezfseccx';
    show 'chat';
};

1;

