#!/usr/bin/env perl
package App::Dataninja::Bot;
use Moose;
use DateTime;
use Path::Dispatcher;
use App::Dataninja::Bot::Dispatcher;
use App::Dataninja::Bot::Plugin;
use List::Util qw/first/;

sub record_and_say {
    my $self = shift;
    my %args = @_;
    $args{emotion} ||= 0;

    $self->schema->add_message(
        nick    => lc $self->config->site->{nick},
        message => $args{body},
        channel => $args{channel},
        network => $self->assigned_network,
        emotion => $args{emotion},
    );

    if ($args{emotion}) {
        $self->emote(%args);
    }
    else {
        $self->say(%args);
    }
}

sub _said {
    my $self = shift;
    my $args = shift;
    print STDERR sprintf('< %s> %s', $args->{'who'}, $args->{'body'}), "\n";

    $args->{'network'} = $self->assigned_network;
    my $message_data = $self->schema->add_message(%args);

    my $bot_nick = $self->config->site->{'nick'};
    my $network_config = $self->config->site->{'networks'}->{$args->{'network'}};

    my $channel_config =
    first { $_->{'name'} eq $args->{'channel'} }
    @{$network_config->{'channels'}};

    my $set_prefix = exists $channel_config->{'prefix'}
    ? $channel_config->{'prefix'}
    : $network_config->{'prefix'};

    my $prefix_rule;

    $prefix_rule = Path::Dispatcher::Rule::Regex->new(
        prefix => 1,
        regex => qr{^($bot_nick: |$set_prefix)},
    );

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
        defined $match->result
            ? (
                ref($match->result) eq 'ARRAY'
                    ? $match->result->[0]
                    : $match->result
                )
            : '',
        $message_data,
        $self->schema,
    );
}

sub said {
    my $self = shift;
    my $args = shift;

    # B:BB strips the address if we are addressed
    $args->{body} = "$args->{address}: $args->{body}"
    if $args->{address} && $args->{address} ne 'msg';

    my $said = $self->_said($args, @_);
    $self->schema->log_response(
        response => $said,
        channel => $args{channel},
    ) if defined($said);

    substr($said, 512) = q{} if $said && length($said) > 512;
    return $said;
}

sub tick {
    my $self = shift;
    my $reminder = $self->schema->first_due_reminder;

    if ($reminder) {
        my $format_module = "DateTime::Format::SQLite";
        my $made_dt = $format_module->parse_datetime($reminder->made);

        # show only if reminder was made more than a month ago
        my $set_message = DateTime->compare(
            $made_dt->add(days => 10),
            DateTime->now
        ) < 0 ? sprintf("(set %s) ", $made_dt->ymd) : '';

        $self->record_and_say(
            channel => $reminder->channel,
            body => sprintf(
                '%s%s: %s',
                $set_message,
                $reminder->remindee,
                $reminder->description,
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
            body    => $interjection->message,
            emotion => $interjection->emotion,
        );

        $interjection->update({interjected => 1});
    }
    return 5;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
