#!/usr/bin/env perl
use strict;
use warnings;
use Template::Declare;
use Template::Declare::Tags;
use Shell::Command;
use List::Util qw/sum/;

# my stuff
use lib 'lib';
use App::Dataninja::Schema;
use App::Dataninja::Config;

if (!-d 'doc/site') {
    mkdir "doc/site" or die "Unable to create doc/site: $!";
}

sub my_mkdir {
    my $dir = shift;
    if (!-d "doc/site/$dir") {
        mkdir "doc/site/$dir" or die "Unable to create doc/site/$dir: $!";
    }
}

sub write_to {
    my $file = shift;
    my $td = shift;

    my $fh;
    open $fh, ">doc/site/$file";
    print {$fh} $td;
    close $fh;

    print STDERR "Wrote to doc/site/$file\n";
    return 1;
}

my $schema = App::Dataninja::Schema->connect_with_defaults;


my @networks = map { $_->network } $schema->resultset('Message')->search(
    undef,
    {
        columns => ['network'],
        distinct => 1,
    }
);

my %channels;

for my $network (@networks) {
    $channels{$network} = [
        grep { /^#/ } map {
            $_->channel
        } $schema->resultset('Message')->search(
            {network => $network},
            {
                columns  => ['channel'],
                distinct => 1,
            }
        )
    ];
}

sub channel_html {
    my $network = shift;
    my $channel = shift;

    my $stats = $schema->resultset('Message')->search(
        {channel => $channel, network => $network}
    );

    my @nicks = map { $_->nick } $stats->search(
        undef,
        {columns => [ qw/nick/ ], distinct => 1}
    );

    my %stats;

    my $nick;
    for $nick (@nicks) {
        my @nick_stats = $stats->search(
            { nick => $nick },
            { columns => [ qw/message/ ] }
        );
        $stats{$nick}->{bytes} = sum map { length $_->message } @nick_stats;
        $stats{$nick}->{lines} = @nick_stats;
        $stats{$nick}->{words} = sum map {my @words = split ' ', $_->message; scalar @words} @nick_stats;
    }

    my $code = html {
        head {
            title { "Stats for $channel on $network" }
            link {
                attr {
                    rel  => 'stylesheet',
                    href => '/css/main.css',
                    type => 'text/css',
                }
            }
        }
        body {
            h1 { "Stats for $channel on $network" }
            table {
                attr { border => 1 }
                row { cell { $_ } for (qw/Nick Bytes Lines Words/) };
                foreach $nick (reverse sort {
                        $stats{$a}->{bytes} <=> $stats{$b}->{bytes}
                    } @nicks) {
                    row {
                        cell { $nick                  }
                        cell { $stats{$nick}->{bytes} }
                        cell { $stats{$nick}->{lines} }
                        cell { $stats{$nick}->{words} }
                    }
                }
            }
            hr {}
            small {
                em { "Page last generated " . localtime() }
            }
        }
    };

    return $code;
}

my $index_code = html {
    head {
        title { "Stats for dataninja" }
        link {
            attr {
                rel  => 'stylesheet',
                href => '/css/main.css',
                type => 'text/css',
            }
        }
    }
    body {
        h1 { "Dataninja stats" }
        ul {
            for my $network (keys %channels) {
                my_mkdir "$network";
                li { $network }
                ul {
                    for my $channel (@{$channels{$network}}) {
                        (my $link = $channel) =~ s/\W//g;
                        $link = "$network/$link";
                        my_mkdir "$link";
                        write_to(
                            "$link/index.html",
                            channel_html($network, $channel)
                        );

                        my @stats = $schema->resultset('Message')->search(
                            {channel => $channel, network => $network},
                            { columns => [qw/message/] }
                        );
                        li {
                            a { attr { href => "$link/index.html" } $channel };
                            span {
                                attr { class => 'main_stats' }
                                "L: " . scalar(@stats) . " | " .
                                "B: " . sum map { length $_->message} @stats
                            };
                        }
                    }
                }
            }
        }
        hr {}
        small {
            em { "Page last generated " . localtime() }
        }
    }
};

write_to('index.html', $index_code);
