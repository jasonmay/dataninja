#!/usr/bin/env perl
package Dataninja::View;
use strict;
use warnings;
use Jifty::View::Declare -base;
use Carp;

template '/' => page {
    h1 { 'Welcome to Dataninja!' };
};

template networks => sub {
    my $networks = Dataninja::Model::MessageCollection->new;
    $networks->unlimit;
    $networks->column(function => 'distinct', column => 'network');
    $networks->clear_order_by;

    h1 { "Networks" }
    ul {
        li {
            Jifty->web->link(
                label => $_->network,
                url => '/stats/' . $_->network
            )
        } for @$networks
    }
};

template network_stats => sub {
    my $self = shift;
    my $network = shift;

    my $channels = Dataninja::Model::MessageCollection->new;
    $channels->limit(column => 'network', value => $network);
    $channels->column(function => 'distinct', column => 'channel');
    $channels->clear_order_by;
    
    h1 { "Channels under $network" }
    ul {
        li {
            my $channel = $_->channel;
            $channel =~ s/^#//;
            Jifty->web->link(
                label => $_->channel,
                url => sprintf("/stats/%s/%s", $network, $channel)
            )
        } for @$channels
    }

};

template channel_stats => sub {
    my $self = shift;
    my $network = shift;
    my $channel = shift;
    warn "Network: $network\nChannel: $channel";
   
	table {
        attr { class is 'stats' };

		row {
			th { 'Nick' }
			th { 'Bytes' }
			th { 'Lines' }
		};

		my $messages = Dataninja::Model::MessageCollection->new;
        $messages->limit(column => 'network', value => $network);
        $messages->limit(column => 'channel', value => $channel);
		$messages->column(column => 'nick');

		$messages->column(	column => 'bytes',
							function => 'sum(length(message))');

		$messages->column(	column => 'lines',
							function => 'count(*)');

		$messages->group_by(column => 'nick');
		$messages->order_by(function => 'sum(length(message))',
							order => 'desc');


		while (my $message = $messages->next)
		{
			row {
				cell { $message->nick->name }
				cell { $message->bytes }
				cell { $message->lines }
			}
		}
	}

};

template stats => page {
    my ($network, $channel, $nick) = map { get $_ } qw(network channel nick);
    if ($nick) {
        p { "Network: $network" }
        p { "Channel: $channel" }
        p { "Nick: $nick" }
    }
    elsif ($channel) {
        show('channel_stats', $network, $channel);
    }
    elsif ($network) {
        show('network_stats', $network);
    }
    else {
        show 'networks';
    }
};

template chat => page  {
    my $messages = Dataninja::Model::MessageCollection->new;
    $messages->unlimit;
    $messages->rows_per_page(10);
    $messages->order_by(column => 'moment', order => 'desc');
    p { a { attr { href is '/chat' } 'Refresh' } }
    table {
        while (my $m = $messages->next) {
            row {
                cell { sprintf "[%s]", $m->moment }
                cell { sprintf "<%s>", $m->nick->name }
                cell { $m->message }
            }
        }
    }
    form {
        my $action = new_action(class => 'AddInterjection');
        Jifty->web->form->register_action($action);
        render_param($action => 'message');
        render_param(
            $action => 'network',
            default_value => 'efnet',
            render_as => 'Hidden'
        );
        render_param(
            $action => 'channel',
            default_value => '#netmonster',
            render_as => 'Hidden'
        );
        form_submit(
            submit  => $action,
            label   => 'Say it',

            onclick => [
                { submit => $action },
                {
                    args => {
                        id => { result_of => $action, name => 'id' },
                    },
                }
            ],
        );
    }
};


1;

