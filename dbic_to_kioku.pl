#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use lib 'lib';
use App::Dataninja::Model;

use DBI;
use DateTime::Format::Pg;
use DateTime;
use Try::Tiny;

clear_db();

my $dbh = DBI->connect('dbi:Pg:dbname=dataninja', 'jasonmay', $ENV{DATANINJA_LEGACY_PASS});
my $k = App::Dataninja::Model->new(dsn => 'dbi:SQLite:dbname=dataninja');

say 'Inserting networks...';
$k->scoped_txn(sub { insert_networks($dbh, $k) });

say 'Inserting nicks...';
$k->scoped_txn(sub { insert_nicks($dbh, $k) });

say 'Inserting channels...';
$k->scoped_txn(sub { insert_channels($dbh, $k) });

say 'Inserting messages...';
insert_messages($dbh, $k);

say 'Inserting reminders...';
$k->scoped_txn(sub { insert_reminders($dbh, $k) });

say 'Inserting interjections...';
$k->scoped_txn(sub { insert_interjections($dbh, $k) });

my $count = 1;
my $e     = 1;

sub clear_db {
    unlink 'dataninja';
}

sub insert_networks {
    my $dbh = shift;
    my $k   = shift;

    my $sth = $dbh->prepare('select distinct network from messages');
    $sth->execute;

    my %servers = (
        efnet    => 'irc.efnet.net',
        nm       => 'verne.freenode.net',
        freenode => 'verne.freenode.net',
        dev      => 'localhost',
        work     => 'verne.freenode.net',
        cplug    => 'irc.cplug.net',
    );
    while (my $row = $sth->fetchrow_hashref) {
        my $network = App::Dataninja::Schema::Network->new(
            name   => $row->{network},
            server => $servers{$row->{network}},
            port   => 6667,
        );

        $k->insert($network);
    }
}

sub insert_nicks {
    my $dbh = shift;
    my $k   = shift;

    my $sth = $dbh->prepare("select m.network, m.nick, a.location from messages m left join areas a on (a.nick = m.nick and a.network = m.network) group by m.network, m.nick, a.location");
    $sth->execute;

    while (my $row = $sth->fetchrow_hashref) {
        my $network = $k->lookup_network($row->{network})
            or die "network $row->{network} not found in directory";

        my $nick = App::Dataninja::Schema::Nick->new(
            name    => $row->{nick},
            network => $network,
            $row->{location} ? (location => $row->{location}) : (),
        );

        $k->insert($nick);
    }
}

sub insert_channels {
    my $dbh = shift;
    my $k   = shift;

    my $sth = $dbh->prepare('select distinct channel, network from messages');
    $sth->execute;

    while (my $row = $sth->fetchrow_hashref) {
        my $network = $k->lookup_network($row->{network})
            or die "network $row->{network} not found in directory";

        my $nick = App::Dataninja::Schema::Channel->new(
            name    => $row->{channel},
            network => $network,
        );

        $k->insert($nick);
    }
}

my %reminder_cache = ();
sub insert_messages {
    my $sth = $dbh->prepare('select * from messages');
    $sth->execute;

    ($count, $e) = (1, 1);
    my @batch;
    while (my $row = $sth->fetchrow_hashref) {
        {
            my $scope = $k->new_scope;

            my $channel = $k->lookup_channel($row->{network}, $row->{channel})
                or die "channel $row->{channel} not found in directory";

            my $nick    = $k->lookup_nick($row->{network}, $row->{nick});
            my $moment  = DateTime::Format::Pg->parse_datetime($row->{moment});
            my $body = $row->{message};

            my %properties = (
                emotion => $row->{emotion}, # /me ...
            );

            my $message = App::Dataninja::Schema::Message->new(
                legacy_id  => $row->{id},
                nick       => $nick,
                channel    => $channel,
                body       => $body,
                said_at    => $moment,
                properties => \%properties,
            );

            $reminder_cache{$row->{id}} = $message if $body =~ /^#remind/;
            say 2**$e++ . ' messages inserted... ' if 2**$e == $count++;
            push @batch, $message;
        }

        if (@batch >= 500) {
            $k->scoped_txn(sub { $k->insert(splice @batch); });
        }
    }
}

sub _get_message_from_id {
    my $k  = shift;
    my $id = shift;

    return $k->directory->backend->schema->resultset('entries')->search({legacy_id => $id})->first;
}

sub insert_reminders {
    # Network and channel on both sides, in case  of missing
    # trigger message records.
    my $sth = $dbh->prepare(
        "select r.id as rid, m.id as mid, m.nick, m.network, m.channel, r.network as r_network, r.channel as r_channel, r.maker, r.remindee, r.reminded, r.canceled, r.description from reminders r inner join messages m on (r.made between m.moment - '3 seconds'::interval and m.moment + '3 seconds'::interval and m.message like '#remind%') order by r.id"
    );
    $sth->execute;

    my (%mids, %rids);

    while (my $row = $sth->fetchrow_hashref) {
        next if $rids{ $row->{rid} }++;
        next if $mids{ $row->{mid} }++;

        my $body     = $row->{description};
        my $remindee = $row->{remindee};
        my $state    = $row->{reminded} ? 'Reminded'  :
                       $row->{canceled} ? 'Cancelled' : 'Active';

        my $trigger_message = $reminder_cache{$row->{mid}};
        my $reminder = App::Dataninja::Schema::Reminder->new(
            body         => $body,
            remindee     => $remindee,
            state        => $state,
            triggered_by => $trigger_message,
        );
        $k->insert($reminder);

        say 2**$e++ . ' reminders inserted...' if $count == 2**$e;

        $count++;
    }
}

sub insert_interjections {
    my $sth = $dbh->prepare('select * from interjections');
    $sth->execute;

    while (my $row = $sth->fetchrow_hashref) {
        my $scope = $k->new_scope;

        my $channel = $k->lookup_channel($row->{network}, $row->{channel})
            or die "channel $row->{channel} not found in directory";

        my $interjected = $row->{interjected} || 0;

        my $body = $row->{message};

        my %properties = (
            emotion => $row->{emotion}, # /me ...
        );

        my $interjection = App::Dataninja::Schema::Interjection->new(
            channel     => $channel,
            body        => $body,
            interjected => $interjected,
            properties  => \%properties,
        );

        $k->insert($interjection);
    }
}
