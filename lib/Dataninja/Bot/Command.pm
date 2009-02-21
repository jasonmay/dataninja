#!/usr/bin/env perl
package Dataninja::Bot::Command;
use strict;
use warnings;

=head1 DESCRIPTION

This module acts as a superclass for all the commands the bot will support. The
following methods are to be overridden in the command subclasses.

=head1 METHODS

=head2 pattern

This method returns a regular expression denoting when the command will be
triggered.

=cut

sub pattern { qr|^burp$| }

=head2 run

This method is what is run when the command is triggered. The return value is
the resulting response the bot will say.

=cut

sub run     { "burp" }

=head2 help

The return value of this method is to be a helpful description of what the
command does.

=cut

sub help    { "burp" }

=head2 usage

The return value of this method is to be a brief sample of how to use the
command.

=cut

sub usage   { "burp [...]" }

1;

