#!/usr/bin/env perl
package Dataninja::Bot::Command::Monologue;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';

sub pattern { qr|^#monologue\b$| }

sub run {
    my $args = shift;

    my $messages = Dataninja::Model::MessageCollection->new;
    $messages->limit(
        column         => 'nick',
        operator       => '!=',
        value          => $args->{who},
    );

    $messages->column(
        column => 'moment',
        function => 'max',
        alias => 'max_moment'
    );

    $messages->clear_order_by;
    warn $messages->build_select_query;

    my $latest_by_other = $messages->next;
    return "fail";
    return "uhhh" unless $latest_by_other->moment;

    my $messages_monologue = Dataninja::Model::MessageCollection->new; # reboot!
    $messages_monologue->limit(
        column           => 'moment',
        case_sensitive   => 1,
        operator         => '>',
        value            => $latest_by_other->moment->ymd . ' ' . $latest_by_other->moment->hms,
    );
    
    return $messages_monologue->count;
}

1;
