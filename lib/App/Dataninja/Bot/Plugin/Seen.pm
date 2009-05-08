package App::Dataninja::Bot::Plugin::Seen;
use Moose;
extends 'App::Dataninja::Bot::Plugin';
use DateTime::Format::Pg;
use DateTime::Duration;
use DateTime::Format::Human::Duration;

=head1 NAME

App::Dataninja::Bot::Plugin::Seen - the bot tells you when someone was last seen

=head1 COMMANDS

=over

=item * seen B<nick>

=back

=cut

sub get_latest_timestamp_of {
    my $self = shift;
    my $nick = shift;

    my $row = $self->rs('Message')->find(
        {
            nick => $nick,
        },
        {
            order_by => 'moment desc',
            rows     => 1,
        }
    );

    return defined $row ? $row->moment : undef;
}

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        seen => sub {
            # oops accidentally commited WIP code earlier!
            return "under construction for now :/";
#            my $command_args = shift;
#            my $nick         = lc $command_args;
#            return "seen who?" unless $nick;
#
#            my $latest_moment = DateTime::Format::Human::Duration->new->format_duration_between(
#                DateTime::Format::Pg->parse_datetime($self->get_latest_timestamp_of($nick)),
#                DateTime->now
#            );
#            return "haven't seen anyone who goes by that nick"
#                unless defined $latest_moment;
#            my $message = $self->rs('Message')->search(
#                {
#                    moment => $latest_moment,
#                    nick   => $nick,
#                }
#            )->single->message;
#
#            return
#                sprintf(
#                    "%s: <%s> %s",
#                    $latest_moment,
#                    $nick,
#                    $message
#                );
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

