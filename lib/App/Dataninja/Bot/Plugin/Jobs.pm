package App::Dataninja::Bot::Plugin::Jobs;
use Moose;
use URI;
use Web::Scraper;
extends 'App::Dataninja::Bot::Plugin';

=head1 NAME

App::Dataninja::Bot::Plugin::Jobs - you supply craigslist subdomain and search query,
the bot responds with results

=head1 COMMANDS

=over

=item * jobs B<[area]> B<[query]>

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        jobs => sub {
            my $command_args = shift;
            my ($place, $search_query) = ($command_args =~ /^\W* (\w+) (?:\s+ (.+))?/x);
            return "usage: jobs <area> <description>" unless $place;

            my $craigslist = scraper {
                process 'blockquote>p>a', 'titles[]' => 'TEXT';
            };

            my $url_query;
            $url_query = ($search_query ? "?query=$search_query" : '');
#            my $query = Jifty->config->app("clquery");
            my $job_data = eval { $craigslist->scrape(URI->new("http://$place.craigslist.org/search/jjj/$url_query")) };
            return "not a craigsilst subdomain" if $@ && $@ =~ /500/;
            return $@ if $@;

            my @jobs = @{defined $job_data->{titles} ? $job_data->{titles} : []};

            return "no jobs available right now" unless @jobs;

            return join q{, } =>
            map {
                my @words = split ' ', $_;
                $_ = join ' ', @words[0 .. ($#words > 4 ? 4 : $#words)];
                chop while /[^\w\d]$/;
                "[$_]";
            }
            (@jobs[0 .. ($#jobs > 4 ? 4 : $#jobs)]);
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

