#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Unit;
use base 'Dataninja::Bot::Command';
use WWW::Google::Calculator;

=head1 DESCRIPTION

Reminds a user to blah blah TODO

=cut

sub pattern { qr/^#u(?:nit)?\s+(.+)$/ }

{
    my @history;
    sub run {
        my $calc = WWW::Google::Calculator->new;
        return eval {
            my $modified_input = $1;
            $modified_input
                =~ s/\$(\d)/(@history > $1) ? $history[$1] : \$$1/eg;
           
            warn "modified: $modified_input";
            my $ret = $calc->calc($modified_input);
            if (defined $ret) {
                if ($ret =~ /^.*=\s*(.*)$/) {
                    unshift @history, $1;
                    warn "$1 added to history";
                }
                return $ret;
            }
            return "huh?";
        } unless $@;
        return $@;
    }
}

1;
