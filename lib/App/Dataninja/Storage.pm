package App::Dataninja::Storage;
use strict;
use warnings;
use Moose;
use App::Dataninja::Config;

=head1 NAME

App::Dataninja::Schema - L<DBIx::Class> schema for the App::Dataninja database

=head1 METHODS

=head2 connect_with_defaults

This method wraps around C<connect> and connects with the database
configuration provided by L<App::Dataninja::Config>. It takes in the same
arguments L<App::Dataninja::Config> does.

See L<DBIx::Class::Schema> for other methods.

=head1 TABLES

=over

=item * Area

=item * Interjection

=item * Message

=item * Nick

=item * Reminder

=back

=cut

has config => (
    is  => 'rw',
    isa => 'App::Dataninja::Config',
);

has profile => (
    is  => 'rw',
    isa => 'Str',
);

has schema => (
    is => 'rw',
    isa => 'DBIx::Class::Schema',
    lazy => 1,
    builder => '_build_schema',
    handles => ['resultset'],
);

sub _build_schema {
    my $self = shift;

    return App::Dataninja::Schema->connect(
        sprintf(
            'dbi:%s:dbname=%s',
            $self->config->main->{database}{driver},
            $self->config->main->{database}{name},
        ),
        $self->config->main->{database}{user},
        $self->config->main->{database}{pass},
    ) or die $!;
}

sub add_message {
    my $self = shift;
    my %args = @_;

    my @columns = qw/ nick message channel network moment emotion /;

    for (keys %args) {
        delete @args{ grep {!$args{$_}} @columns };
    }

    $args{emotion} ||= 0;
    $self->resultset('Message')->create(
        {
            nick    => lc($args{nick}),
            message => $args{message},
            channel => lc($args{channel}),
            network => $args{profile} || $self->profile, # trying to transition
            moment  => $args{moment} || DateTime->now,
            emotion => $args{emotion},
        }
    );
}

sub first_due_reminder {
    my $self = shift;

    return $self->resultset('Reminder')->find(
        {
            network  => $self->profile,
            reminded => 0,
            canceled => 0,
            moment   => {'<' => DateTime->now }
        },
        { rows => 1 },
    );
}

sub first_interjection {
    my $self = shift;
    return $self->resultset('Interjection')->find(
        {
            network     => $self->profile,
            interjected => 0,
        },
        { rows => 1 },
    );
}

sub log_response {
    my $self = shift;
    my %args = @_;

    $self->add_message(
        nick    => lc($self->config->site->{'nick'}),
        message => $args{response},
        channel => $args{channel},
        profile => $self->profile,
    );
}

sub latest_message_of {
    my $self = shift;
    my $nick = shift;

    return $self->resultset('Message')->find(
        {
            nick => $nick,
        },
        {
            order_by => \'moment desc',
            rows     => 1,
        }
    );
}

1;

