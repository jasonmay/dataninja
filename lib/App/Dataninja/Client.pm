package App::Dataninja::Client;
use Moose;
extends 'Reflex::Base';

use Reflex::POE::Session;
use Reflex::Interval;
use Reflex::Trait::Watched 'watches';
use POE 'Component::IRC';

has component => (
    is  => 'rw',
    isa => 'Object|Undef',
);

watches poco_watcher => (
    role => 'poco',
    isa  => 'Reflex::POE::Session',
);

watches clock => (
    isa => 'Reflex::Interval',
    is  => 'rw',
    setup => {
        interval    => 5,
        auto_repeat => 1,
    },
);

sub BUILD {
    my $self = shift;

    # This is only really necessary because we're using
    # POE::Component::IRC's OO interface.
    $self->component(
        POE::Component::IRC->spawn(
            nick    => "dataninja",
            ircname => "dataninja",
            server  => "localhost",
        ) || die "Drat: $!"
    );

    # Start a Reflex::POE::Session that will
    # subscribe to the IRC component.
    $self->poco_watcher(
        Reflex::POE::Session->new(
            sid => $self->component->session_id,
        )
    );

    # run_within_session() allows the component
    # to receive the correct $_[SENDER].
    $self->run_within_session(
        sub {
            # The following two lines work because
            # PoCo::IRC implements a yield() method.
            $self->component->yield(register => "all");
            $self->component->yield(connect  => {});
        }
    )
}

sub on_poco_irc_001 {
    my $self = shift;
    $self->component->yield(join  => '#dataninja');
}

sub on_poco_irc_join {
    my $self = shift;
    my ($args) = @_;
    my ($who, $channel, $what) = @$args{0, 1};
    my $nick = (split /!/, $who)[0];
    warn "$nick joins $channel\n";
}

sub on_poco_irc_part {
    my $self = shift;
    my ($args) = @_;
    my ($who, $channel, $what) = @$args{0, 1};
    my $nick = (split /!/, $who)[0];
    warn "$nick leaves $channel\n";
}

sub on_poco_irc_quit {
    my $self = shift;
    my ($args) = @_;
    my ($who, $channel, $what) = @$args{0, 1};
    my $nick = (split /!/, $who)[0];
    warn "$nick quits $channel\n";
}

sub on_poco_irc_public {
    my $self = shift;
    my ($args) = @_;

    my ($who, $where, $what) = @$args{0, 1, 2};

    my $nick = (split /!/, $who)[0];
    my $channel = $where->[0];

    warn "<$nick> $what\n";
}

# TODO have dataninja return reminders privately
sub on_poco_irc_msg {
    my $self = shift;
    my ($args) = @_;

    my ($who, $where, $what) = @$args{0, 1, 2};

    my $nick = (split /!/, $who)[0];
    my $channel = $where->[0];

    warn "<$nick> $what\n";
}

sub on_clock_tick { warn "test" }

no Moose;

1;
