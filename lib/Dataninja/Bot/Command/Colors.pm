#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Colors;
use base 'Dataninja::Bot::Command';

=head1 DESCRIPTION

Show ansi colors and the numbers the correspond

=cut

sub pattern { qr/^#colors\b/ }

sub run {
    return join q{ },
        map {
            "\e[0;3${_}m${_}\e[1;3${_}m${_}\e[0m"
        } (0 .. 7);
}

sub usage { "#colors" }

1;
