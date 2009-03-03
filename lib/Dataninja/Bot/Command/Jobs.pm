#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Jobs;
use URI;
use Web::Scraper;
use base 'Dataninja::Bot::Command';

=head1 DESCRIPTION

Checks jobs on Craigslist

=cut

sub pattern { qr/^#jobs\b/ }

sub run {
my $craigslist = scraper {
    process 'blockquote>p>a', 'titles[]' => 'TEXT';
};

my $query = Jifty->config->app("clquery");
my $job_data = $craigslist->scrape(URI->new("http://york.craigslist.org/search/jjj?query=$query"));

my @jobs = @{$job_data->{titles}};

return join q{, } =>
    map {
        my @words = split ' ', $_;
        $_ = join ' ', @words[0 .. ($#words > 4 ? 4 : $#words)];
        chop while /[^\w\d]$/;
#        warn $_;
        "[$_]";
    }
    (@jobs[0 .. ($#jobs > 4 ? 4 : $#jobs)]);
}

sub usage { "#jobs" }

1;
