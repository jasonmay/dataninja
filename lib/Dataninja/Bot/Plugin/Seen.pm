package Dataninja::Bot::Plugin::Seen;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';
use DateTime::Format::Pg;
use DateTime::Duration;
use DateTime::Format::Duration;

sub get_latest_timestamp_of {
    my $self = shift;
    my $nick = shift;

    my $messages = Dataninja::Model::MessageCollection->new;
    $messages->limit(column => 'nick', value => $nick);
    $messages->order_by(column => 'moment', order => 'desc');
    $messages->rows_per_page(1);
    return "haven't seen anyone who goes by that nick"
        if $messages->count == 0;
    my $message = $messages->next;
    return $message->moment if $message->can('moment');
    return "nope";
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
            my $messages      = Dataninja::Model::MessageCollection->new;
            $messages->limit(column => 'moment', value => $latest_moment);
            $messages->limit(column => 'nick',   value => $nick);
            my $message = $messages->next;

            return
                sprintf(
                    "%s: <%s> %s",
                    $latest_moment,
                    $nick,
                    $message->message
                );
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

