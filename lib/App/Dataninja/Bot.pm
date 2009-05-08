#!/usr/bin/env perl
package App::Dataninja::Bot;
use Moose;
use DateTime;
use Path::Dispatcher;
use App::Dataninja::Bot::Dispatcher;
use App::Dataninja::Bot::Plugin;
use List::Util qw/first/;
use MooseX::NonMoose;
use Module::Pluggable
    search_path => ['App::Dataninja::Bot::Plugin'],
    sub_name    => 'plugins';
extends 'Bot::BasicBot';

=head1 NAME

App::Dataninja::Bot - the core interface needed to run the IRC bot

=head1 SYNOPSIS

  my $bot = App::Dataninja::Bot->new(
      assigned_network => '...',
      config           => App::Dataninja::Config->new(...),
      schema           => App::Dataninja::Schema->new(...),
  );

  $bot->search_path(add => 'My::Own::Plugins');

  $bot->run;

=head1 DESCRIPTION

See C<examples/> in the dist for examples of extending L<App::Dataninja>.

=head1 ATTRIBUTES

=head2 dispatcher

(C<Path::Dispatcher>) The object that L<App::Dataninja> uses to parse the IRC users' input.

=head2 assigned_network

(C<Str>) The network on which the L<App::Dataninja> process resides.

=head2 config

(L<App::Dataninja::Config>) The configuration structure loaded from YAML file(s).

=head2 schema

(L<App::Dataninja::Schema>) The interface that L<App::Dataninja> uses to interact with the
database.

=head2 plugins

(C<ArrayRef[Str]>) The list of plugins provided by L<App::Dataninja>.

=cut

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
    isa => 'App::Dataninja::Config',
);

has schema => (
    is => 'rw',
    isa => 'App::Dataninja::Schema',
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

sub FOREIGNBUILDARGS {
    my $class = shift;
    my %args = @_;
    my %networks = %{$args{config}->site->{networks}};
    my %network_lookup = map { ($_ => 1) } keys(%networks);

    die "Unknown network: $args{assigned_network}"
        unless exists $network_lookup{$args{assigned_network}};

    my %new_args = (
        server => $networks{$args{assigned_network}}->{server},
        port   => "6667",
        channels => [
            map {
                $_->{name}
            } @{$networks{$args{assigned_network}}->{channels}}
        ],

        nick      => $args{config}->site->{nick},
        alt_nicks => $args{config}->site->{nick} . '2',
        username  => $args{config}->site->{nick},
        name      => "IRC Bot",
    );

    return %new_args;
}

=head2 record_and_say

A wrapper around 'say' that logs the IRC message to the database as well as
talk to the IRC channel.

=cut

sub record_and_say {
    my $self = shift;
    my %args = @_;

    $self->schema->resultset('Message')->create({
        nick    => lc $self->config->site->{nick},
        message => $args{body},
        channel => $args{channel},
        network => $self->assigned_network,
        moment  => DateTime->now,
    });

    $self->say(%args);
}

sub _said {
    my $self = shift;
    my $args = shift;
    print STDERR sprintf('< %s> %s', $args->{'who'}, $args->{'body'}), "\n";

    $args->{'network'} = $self->assigned_network;
    my $message_data = $self->schema->resultset('Message')->create({
        nick    => lc $args->{'who'},
        message => $args->{'body'},
        channel => $args->{'channel'},
        network => $args->{'network'},
        moment  => DateTime->now,
    });

    my $bot_nick = $self->config->site->{'nick'};
    my $network_config = $self->config->site->{'networks'}->{$args->{'network'}};

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

    my $dispatcher = App::Dataninja::Bot::Dispatcher->new(
        prefix    => $prefix_rule,
        plugins   => [$self->plugins],
        data_for_plugins => App::Dataninja::Bot::Plugin->new(
            message_data => $message_data,
            schema   => $self->schema,
        )
    );
    my $dispatch = $dispatcher->dispatch($args->{'body'});
    return undef unless $dispatch->has_matches;
    my $match = ($dispatch->matches)[0];
    return $dispatch->run(
        defined $match->result ? $match->result->[0] : '',
        $message_data,
        $self->schema,
    );
}

=head2 said [HASHREF]

Overridden method from L<Bot::BasicBot> that parses IRC input (public msg). The
appropriate response is returned. The method returns undef if the bot doesn't
want to respond.

=cut

sub said {
    my $self = shift;
    my $args = shift;

    # B:BB strips the address if we are addressed
    $args->{body} = "$args->{address}: $args->{body}"
        if $args->{address} && $args->{address} ne 'msg';

    my $said = $self->_said($args, @_);
    $self->schema->resultset('Message')->create({
        nick    => lc $self->config->site->{'nick'},
        message => $said,
        channel => $args->{channel},
        moment  => DateTime->now,
        network => $self->assigned_network,
    }) if defined($said);

    substr($said, 512) = q{} if $said && length($said) > 512;
    return $said;
}

=head2 run

The method to run the L<App::Dataninja> bot.

=cut

sub run {
    my $self = shift;
    $self->SUPER::run(@_);
}

=head2 tick

This was overridden to probe the reminders table for any reminders that need
mentioned to its corresponding remindee.

=cut

sub tick {
    my $self = shift;
    my $reminder = $self->schema->resultset('Reminder')->find(
        {
            network  => $self->assigned_network,
            reminded => 0,
            canceled => 0,
            moment => {'<' => DateTime->now }
        },
        { rows => 1 },
    );

    if ($reminder) {
        $self->record_and_say(
            channel => $reminder->channel,
            body => sprintf(
                '%s: %s',
                $reminder->remindee,
                $reminder->description
            )
        );

        $reminder->update({reminded => 1});
    }

    my $interjection = $self->schema->resultset('Interjection')->find(
        {
            network     => $self->assigned_network,
            interjected => 0,
        },
        { rows => 1 },
    );
    if ($interjection) {
        $self->record_and_say(
            channel => $interjection->channel,
            body    => $interjection->message
        );


        $interjection->update({interjected => 1});
    }
    return 5;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
