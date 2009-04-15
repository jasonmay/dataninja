#!/usr/bin/env perl
package Dataninja::Bot::Interface;
use Moose;
use DateTime;
use Module::Refresh;
use Path::Dispatcher;
use Dataninja::Bot::Dispatcher;
use List::Util qw/first/;

extends 'Bot::BasicBot';
with 'MooseX::Alien';

has rules => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

has dispatcher => (
    is => 'rw',
    isa => 'Path::Dispatcher',
    default => sub { Path::Dispatcher->new },
);

has assigned_network => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has config => (
    is => 'rw',
    isa => 'Dataninja::Config',
);

has schema => (
    is => 'rw',
    isa => 'Dataninja::Schema',
);

=head1 METHODS

=head2 load_modules

Loads all the commands for the bot to use on IRC.

=cut

=head2 init

Overridden method for loading the modules.

=cut

sub init {
    my $self = shift;
    return 1;
}

=head2 new NETWORK

Overridden to specify a network as a string for the param.

=cut

around 'new' => sub {
    my $orig = shift;
    my $class = shift;
    my $config = $_[0];
    my $assigned_network = $_[1] || 'dev';
    my $schema = $_[2];

    my %networks = %{$config->site->{networks}};
    my %network_lookup = map { ($_ => 1) } keys(%networks);

    die "Unidentified network" unless $network_lookup{$assigned_network};

    my %args = (
        server => $networks{$assigned_network}->{server},
        port   => "6667",
        channels => [
            map {
                $_->{name}
            } @{$networks{$assigned_network}->{channels}}
        ],

        nick      => $config->site->{nick},
        alt_nicks => $config->site->{nick} . '2',
        username  => $config->site->{nick},
        name      => "IRC Bot",
    );

    my $self = $class->$orig(%args);
    $self->assigned_network($assigned_network);
    $self->config($config);
    $self->schema($schema);
    return $self;
};

sub record_and_say {
    my $self = shift;
    my %args = @_;

    my $message = Dataninja::Model::Message->new;
    $message->create(
        nick    => lc $self->config->site->{nick},
        message => $args{body},
        channel => $args{channel},
        network => $self->assigned_network,
        moment  => DateTime->now,
    );

    $self->say(%args);
}

sub _said {
    my $self = shift;
    my $args = shift;
    warn sprintf('< %s> %s', $args->{'who'}, $args->{'body'});

    $args->{'network'} = $self->assigned_network;
    $self->schema->resultset('Message')->create({
        nick    => lc $args->{'who'},
        message => $args->{'body'},
        channel => $args->{'channel'},
        network => $args->{'network'},
        moment  => DateTime->now,
    });

    my $bot_nick = $self->config->{'nick'};
    my $network_config = $self->config->{'networks'}->{$args->{'network'}};
    my $channel_config =
        first { $_->{'name'} eq $args->{'channel'} }
        @{$network_config->{'channels'}};

    my $set_prefix = exists $channel_config->{'prefix'}
        ? $channel_config->{'prefix'}
        : $network_config->{'prefix'};

    my $prefix_rule;
    {
        no warnings 'uninitialized';
        $prefix_rule = Path::Dispatcher::Rule::Regex->new(
            prefix => 1,
            regex => qr{^($bot_nick: |$set_prefix)},
        );
    }

    my $dispatcher = Dataninja::Bot::Dispatcher->new(
        prefix  => $prefix_rule,
        nick    => lc $args->{'who'},
        message => $args->{'body'},
        channel => $args->{'channel'},
        network => $args->{'network'},
        moment  => DateTime->now,
    );
    my $dispatch = $dispatcher->dispatch($args->{'body'});
    return undef unless $dispatch->has_matches;
    my $match = ($dispatch->matches)[0];
    return $dispatch->run(defined $match->result ? $match->result->[0] : undef);
}

=head2 said [HASHREF]

Overridden method from Bot::BasicBot that parses IRC input (public msg). The
appropriate response is returned. The method returns undef if the bot doesn't
want to respond.

=cut

sub said {
    my $self = shift;
    my $args = shift;
#    my $message = Dataninja::Model::Message->new;

    # B:BB strips the address if we are addressed
    $args->{body} = "$args->{address}: $args->{body}"
        if $args->{address} && $args->{address} ne 'msg';

    warn $self->schema;
    my $said = $self->_said($args, @_);
    $self->schema->resultset('Message')->create({
        nick    => lc $self->config->{'Site'}->{'nick'},
        message => $said,
        channel => $args->{channel},
        moment  => DateTime->now,
        network => $self->assigned_network,
    }) if defined($said);

    substr($said, 512) = q{} if $said && length($said) > 512;
    return $said;
}

=head2 run

One two three four! El oh el!

=cut

sub run {
    my $self = shift;
    $self->SUPER::run(@_);
}

=head2 tick

This was overridden to probe the reminders table for any reminders that need
mentioned to its corresponding remindee.

=cut

#sub tick {
#    my $self = shift;
## {{{
#    my $reminders = Dataninja::Model::ReminderCollection->new;
#    $reminders->limit(column => 'network',  value => $self->assigned_network);
#    $reminders->limit(column => 'reminded', value => 0);
#    $reminders->limit(column => 'canceled', value => 0);
#    $reminders->limit(
#        column => 'moment',
#        operator => '<',
#        value => DateTime->now,
#    );
#
#
#    $reminders->rows_per_page(1);
#    
#    my $reminder = $reminders->next;
#    if ($reminder) {
#        $self->record_and_say(
#            channel => $reminder->channel,
#            body => sprintf(
#                '%s: %s',
#                $reminder->remindee,
#                $reminder->description
#            )
#        );
#
#        $reminder->set_reminded(1);
#    }
# }}}

# {{{
#    my $interjections = Dataninja::Model::InterjectionCollection->new;
#    $interjections->limit(column => 'network',  value => $self->assigned_network);
#    $interjections->limit(column => 'interjected', value => 0);
#
#    $interjections->rows_per_page(1);
#
#    my $interjection = $interjections->next;
#    if ($interjection) {
#        $self->record_and_say(
#            channel => $interjection->channel,
#            body => $interjection->message
#        );
#
#
#        $interjection->set_interjected(1);
#    }
## }}}
#    return 5;
#}

1;
