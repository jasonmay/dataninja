package App::Dataninja::Bot::Plugin::Twitter;
use Moose;
extends 'App::Dataninja::Bot::Plugin';
use Net::Twitter;
use String::Util 'crunch';
use List::Util qw/min max/;
use HTML::Entities;

=head1 NAME

App::Dataninja::Bot::Plugin::Twitter - get the latest tweet of yourself or someone
else

=head1 COMMANDS

=over

=item * twitter B<[tweeter]>

Get the latest tweet by B<tweeter>. If you don't specify a tweeter, it defaults
to your nick.

=back

=cut

sub _render_tweet {
    my $tweet = shift;
    my $text = sprintf '[%s] %s', $tweet->{created_at}, $tweet->{text};
    return decode_entities($text);
}

sub get_latest_tweet {
    my $name = shift;
    my $nth_tweet = shift || 0;

    # Ensure $nth_tweet is only on [0, 19]
    $nth_tweet = min(max($nth_tweet, 0), 19);

    my $twitter = Net::Twitter->new;
    my $responses = $twitter->user_timeline({id => $name});

    return unless defined $responses;
    return $responses->[$nth_tweet];
}

sub get_status_id {
    my $status_id = shift;

    my $twitter = Net::Twitter->new;
    my $response = $twitter->show_status($status_id);

    return unless defined $response;
    return $response;
}

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(twitter => sub {
        my $command_args = crunch(shift);
        my $message_data = shift;

        my ($name, $nth_tweet, $tweet_id, $date) =
            $command_args =~ m<
                ^(\w+)? \s*        # username
                (?:-?(\d+))?       # get the Nth tweet (0-index)
                (?:
                    \#(\d+) |      # get this particular status id
                    (\#\{[^}]+\})  # get the tweet from this date
                )?
            >x;
        $name ||= $message_data->nick;

        my $tweet;
        if (defined $tweet_id) {
            $tweet = get_status_id($tweet_id);
        }
        else {
            $tweet = get_latest_tweet($name, $nth_tweet);
        }
        return sprintf("tweet: %s", _render_tweet($tweet)) if $tweet;

        # at this point, no tweeple exist by that name
        return "that name is not owned by any tweeple";
    });
};
# }}}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

