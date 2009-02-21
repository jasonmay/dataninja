#!/usr/bin/env perl
package Dataninja::Bot::Command::Twitter;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';
use Net::Twitter;

=head1 IRC COMMAND USAGE

  < ircuser> #twitter [username]
  < dataninja> tweet: foo bar baz

=head1 DESCRIPTION

XXX todo.

=cut


sub pattern { qr/^#twitter\s+(\w+)/ }

sub get_latest_tweet {
    my $name = shift;

    my $text = eval {
        my $twitter = Net::Twitter->new(
            username => Jifty->config->app("twitteruser"),
            password => Jifty->config->app("twitterpass"),
        );
        my $responses = $twitter->user_timeline({id => $name});
        $responses->[0]{text};
    };

    return $@ ? "Unable to get ${name}'s latest status." : $text;
}

sub run {
    return "tweet: " . get_latest_tweet($1);
}

1;

