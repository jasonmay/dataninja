#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Interface;
use DateTime;
use Jifty::Everything;
use Module::Refresh;
use Moose;
extends 'Bot::BasicBot';

BEGIN { Jifty->new; }

our @Rules;
my $assigned_network;

=head1 METHODS

=head2 load_modules

Loads all the commands for the bot to use on IRC.

=cut

sub load_modules {
    my $self = shift;

    # construct the commands here
    my $base    = 'lib/Dataninja/Bot/Command/';
    my $pm_base = 'Dataninja::Bot::Command';

    opendir CMD, $base;
    for (readdir CMD) {
        next if $_ eq '.' or $_ eq '..'; 
        next unless -f "$base/$_";
        next unless (my $module_base = $_) =~ s/\.pm$//;
        my $module = "${pm_base}::${module_base}";
#        warn $_;

        {
            my $dispatch;
            my $code = << "CODE";
                require $module;

                \$dispatch->{'name'}     = lc \$module_base;
                \$dispatch->{'code'}     = ${module}->can('run');
                \$dispatch->{'usage'}    = ${module}->can('usage');
                \$dispatch->{'help'}     = ${module}->can('help');
                \$dispatch->{'pattern'}  = ${module}->can('pattern');

                push \@Rules, \$dispatch;
CODE
        
            eval $code;
            die $@ if $@;
        }
    }
    closedir CMD;
    
}

=head2 init

Overridden method for loading the modules.

=cut

sub init {
    load_modules();
    return 1;
}

=head2 new NETWORK

Overridden to specify a network as a string for the param.

=cut

sub new {
    my $self = shift;
    $assigned_network = shift || 'dev';
    my %networks = (
        cplug => {
            server   => 'irc.cplug.net',
            channels => ['#hpm', '#cprb', '#cplug'],
        },
        efnet => {
            server   => 'irc.efnet.net',
            channels => ['#netmonster'],
        },
        freenode => {
            server   => 'irc.freenode.net',
            channels => ['#interhack', '#lanc-lug'],
        },
        dev => {
            server   => 'localhost',
            channels => ['#dataninja'],
        }
    );
    my %network_lookup = map { ($_ => 1) } keys(%networks);

    die "Unidentified network" unless $network_lookup{$assigned_network};

    $self->SUPER::new(
        server => $networks{$assigned_network}->{'server'},
        port   => "6667",
        channels => $networks{$assigned_network}->{'channels'},

        nick      => Jifty->config->app("nick"),
        alt_nicks => [Jifty->config->app("nick") . '2'],
        username  => Jifty->config->app("nick"),
        name      => "IRC Bot",
    );
}

sub record_and_say {
    my $self = shift;
    my %args = @_;

    my $message = Dataninja::Model::Message->new;
    $message->create(
        nick    => lc Jifty->config->app("nick"),
        message => $args{'body'},
        channel => $args{'channel'},
        network => $assigned_network,
        moment  => DateTime->now,
    );

    $self->say(%args);

}

sub _said {
    my $self = shift;
    my $args = shift;
    warn sprintf('< %s> %s', $args->{'who'}, $args->{'body'});

    $args->{'network'} = $assigned_network;
    my $message = Dataninja::Model::Message->new;
    $message->create(
        nick    => lc $args->{'who'},
        message => $args->{'raw_body'},
        channel => $args->{'channel'},
        network => $args->{'network'},
        moment  => DateTime->now,
    );

    foreach my $rule (@Rules) {
        next unless $rule->{pattern};
        
        if ($args->{'body'} =~ $rule->{pattern}->()) {
            if ($rule->{code}) {
                warn "$rule->{name} was selected from $args->{body}";
                my ($response, $new_rules) = $rule->{code}->($args, \@Rules);
                @Rules = @$new_rules if $new_rules; # update rules if modified
                return $response;
            }
            else {
                return ":(\n";
            }
        }
    }
    warn "misc";
    return undef;
}

=head2 said [HASHREF]

Overridden method from Bot::BasicBot that parses IRC input (public msg). The
appropriate response is returned. The method returns undef if the bot doesn't
want to respond.

=cut

sub said { 
    my $self = shift;
    my $args = shift;
    my $message = Dataninja::Model::Message->new;

    my $said = $self->_said($args, @_);
    $message->create(
        nick    => lc Jifty->config->app('nick'),
        message => $said,
        channel => $args->{'channel'},
        moment  => DateTime->now,
        network => $assigned_network
    ) if defined($said);

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

sub tick {
    my $self = shift;
# {{{
    my $reminders = Dataninja::Model::ReminderCollection->new;
    $reminders->limit(column => 'network',  value => $assigned_network);
    $reminders->limit(column => 'reminded', value => 0);
    $reminders->limit(column => 'canceled', value => 0);
    $reminders->limit(
        column => 'moment',
        operator => '<',
        value => DateTime->now,
    );


    $reminders->rows_per_page(1);
    
    my $reminder = $reminders->next;
    if ($reminder) {
        $self->record_and_say(
            channel => $reminder->channel,
            body => sprintf(
                '%s: %s',
                $reminder->remindee,
                $reminder->description
            )
        );

        $reminder->set_reminded(1);
    }
# }}}

# {{{
    my $interjections = Dataninja::Model::InterjectionCollection->new;
    $interjections->limit(column => 'network',  value => $assigned_network);
    $interjections->limit(column => 'interjected', value => 0);

    $interjections->rows_per_page(1);
    
    my $interjection = $interjections->next;
    if ($interjection) {
        $self->record_and_say(
            channel => $interjection->channel,
            body => $interjection->message
        );


        $interjection->set_interjected(1);
    }
# }}}
    return 5;
}

1;
