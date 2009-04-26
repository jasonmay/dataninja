package Dataninja::Bot::Plugin::Seen;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';
use DateTime::Format::Pg;
use DateTime::Duration;
use DateTime::Format::Duration;

sub get_latest_timestamp_of {
    my $self = shift;
    my $nick = shift;

    my $row = $self->rs('Message')->search(
        {
            nick => $nick,
        },
        {
            order_by => 'moment desc',
            rows     => 1,
        }
    )->single;

    return defined $row ? $row->moment : undef;
}

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        seen => sub {
            my $command_args = shift;
            my $nick         = lc $command_args;
            return "seen who?" unless $nick;

            my $latest_moment = $self->get_latest_timestamp_of($nick);
            return "haven't seen anyone who goes by that nick"
                unless defined $latest_moment;
            my $message = $self->rs('Message')->search(
                {
                    moment => $latest_moment,
                    nick   => $nick,
                }
            )->single->message;

            return
                sprintf(
                    "%s: <%s> %s",
                    $latest_moment,
                    $nick,
                    $message
                );
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

