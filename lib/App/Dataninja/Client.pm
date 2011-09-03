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

has model => (
    is       => 'ro',
    isa      => 'App::Dataninja::Model',
    required => 1,
);

has hook_manager => (
    is       => 'ro',
    isa      => 'App::Dataninja::HookManager',
    required => 1,
);

has plugin_manager => (
    is       => 'ro',
    isa      => 'App::Dataninja::PluginManager',
    required => 1,
);

has command_manager => (
    is       => 'ro',
    isa      => 'App::Dataninja::CommandManager',
    required => 1,
);

has network => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
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

    $self->component(
        POE::Component::IRC->spawn(
            nick    => "dataninja",
            ircname => "dataninja",
            server  => "localhost",
        ) || die "Drat: $!"
    );

    $self->poco_watcher(
        Reflex::POE::Session->new(
            sid => $self->component->session_id
        )
    );

    $self->run_within_session(
        sub {
            $self->component->yield(register => "all");
            $self->component->yield(connect  => {});
        }
    );

    $self->_register_default_hooks;
}

sub _register_default_hooks {
    my $self = shift;

    $self->hook_manager->add_hook(
        'public', '_default', sub {
            my ($nick, $channel, $body) = @_;

            my $scope = $self->model->new_scope;
            my $id = $self->model->insert_message(
                network => $self->network,
                nick    => $nick,
                channel => $channel,
                body    => $body,
            );
        }
    );
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

sub _respond {
    my $self    = shift;
    my ($channel, $message) = @_;

    # Hope your IRC client supports unicode!
    $message =~ s/\n/\N{U+2424}/g;
    $message =~ s/\r/\N{U+240D}/g;

    $message = substr($message, 0, 512) if length($message) > 512;

    $self->component->yield(privmsg => $channel => $message);
}

sub on_poco_irc_public {
    my $self = shift;
    my ($args) = @_;

    my ($who, $where, $what) = @$args{0, 1, 2};

    my $nick = (split /!/, $who)[0];
    my $channel = $where->[0];

    $self->hook_manager->invoke_hooks('public', $nick, $channel, $what);

    for my $command ($self->command_manager->commands) {
        # TODO custom prefixes
        if ($what =~ /^\.$command\b/) {
            my $response = $self->command_manager->invoke($command, $channel, $what);
            $self->_respond($channel, $response);
            last;
        }
    }
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

sub on_clock_tick { shift->hook_manager->invoke_hooks('tick') }

no Moose;

1;
