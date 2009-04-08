package Dataninja::Bot::Plugin::Jobs;
use Moose;
use URI;
use Web::Scraper;
extends 'Dataninja::Bot::Plugin::Base';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        jobs => sub {
            my $command_args = shift;
            my ($place, $query) = ($command_args =~ /^\W* (\w+) \s+ (.+)/x);
            return "invalid args" unless $place and $query;

            my $craigslist = scraper {
                process 'blockquote>p>a', 'titles[]' => 'TEXT';
            };

#            my $query = Jifty->config->app("clquery");
            my $job_data = eval { $craigslist->scrape(URI->new("http://$place.craigslist.org/search/jjj?query=$query")) };
            return "not a craigsilst subdomain" if $@ && $@ =~ /500/;
            return $@ if $@;

            my @jobs = @{defined $job_data->{titles} ? $job_data->{titles} : []};

            return "no jobs available right now" unless @jobs;

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
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

