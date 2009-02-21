#!/usr/bin/env perl
package Dataninja::Bot::Command::Last;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';
use App::Nopaste 'nopaste';

=head1 IRC COMMAND USAGE

  < ircuser> #last [number]
  < dataninja> Last [number] lines: http://nopaste.url

=head1 DESCRIPTION

If you use B<#last [number]>, dataninja will respond with
the last B<[number]> lines in that channel. If B<number> is
not specified, dataninja uses 25 as the default.

=cut


sub pattern { qr/^#last(?:\s+(\d+))?/ }

sub _line {
    my ($timestamp, $nick, $message) = @_;
    return sprintf("%s <%s> %s", $timestamp, $nick, $message);
}

sub run {
    my $args = shift;
    my $messages = Dataninja::Model::MessageCollection->new;
    $messages->limit(column => 'network', value => $args->{network});
    $messages->limit(column => 'channel', value => $args->{channel});
    $messages->order_by(column => 'moment', order => 'desc');

    my $num = defined $1 ? $1 : 25;
    $num = 200 if $num > 200;
    $num = 10 if $num < 10;
    $messages->rows_per_page($num);
    
    return "Last $num lines: " . nopaste(
        join qq{\n} =>
            map {
                _line($_->moment, $_->nick->name, $_->message)
            } reverse @$messages
    );
}

1;

