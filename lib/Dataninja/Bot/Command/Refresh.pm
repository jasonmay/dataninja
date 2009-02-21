#!/usr/bin/env perl
package Dataninja::Bot::Command::Refresh;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';
use Module::Refresh;

=head1 DESCRIPTION

Refreshes all the updated commands.

=cut

sub pattern { qr|^#refresh| }

sub run {
    Module::Refresh->refresh;
    return 'I feel refreshed.';
}

1;
