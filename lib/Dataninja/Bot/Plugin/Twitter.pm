package Dataninja::Bot::Plugin::Twitter;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';
use Net::Twitter;
use String::Util 'crunch';

sub get_latest_tweet {
    my $name = shift;

    my $text = eval {
        my $twitter = Net::Twitter->new;
        my $responses = $twitter->user_timeline({id => $name});
        $responses->[0]{text};
    };

    return $@ ? "Unable to get ${name}'s latest status." : $text;
}

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(twitter => sub {
        my $command_args = shift;
        my $name = crunch($command_args) || $self->nick;
        return "tweet: " . get_latest_tweet($name);
    });
};
# }}}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

