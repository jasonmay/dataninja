#!/usr/bin/env perl
package App::Dataninja::Container;
use Moose;
use Bread::Board;
use App::Dataninja::Schema;
use App::Dataninja::Util;
use IM::Engine;
use AE;
use List::Util qw(first);

use Module::Pluggable
    search_path => ['App::Dataninja::Commands'],
    sub_name    => 'commands',
    except      => ['App::Dataninja::Commands::OO'],
;

use Scalar::Util qw(weaken);

has _container => (
    is  => 'rw',
    isa => 'Bread::Board::Container',
    builder => '_build__container',
    handles => ['fetch'],
);

has profile => (
    is  => 'ro',
    isa => 'Str',
    default => 'dev',
);

sub _build__container {
    my $self = shift;
    weaken(my $weakself = $self);
    my $c = container 'Dataninja' => as {

        service profile => $self->profile;

        service schema => (
            class     => 'App::Dataninja::Schema',
            lifecycle => 'Singleton',
            block     => sub {
                my $block = shift;

                my $config = $block->param('config');
                my $schema = App::Dataninja::Schema->connect(
                    sprintf(
                        'dbi:%s:dbname=%s',
                        $config->main->{database}{driver},
                        $config->main->{database}{name},
                    ),
                    $config->main->{database}{user},
                    $config->main->{database}{pass},
                );

                $schema->profile($block->param('profile'));
                $schema->config($block->param('config'));
                return $schema;
            },
            dependencies => wire_names(qw[profile config]),
        );

        service engine => (
            class     => 'IM::Engine',
            lifecycle => 'Singleton',
            block     => sub {
                my ($block) = @_;

                my $profile = $block->param('config')->site->{networks}{$self->profile};

                #die do { require JSON; JSON::to_json($profile); };
                weaken(my $weakblock = $block);
                IM::Engine->new(
                    interface => {
                        protocol     => 'IRC',
                        credentials => {
                            server   => $profile->{server},
                            port     => 6667,
                            channels => [map { $_->{name} } @{$profile->{channels}}],
                            nick     => $block->param('config')->site->{nick},
                        },
                        incoming_callback => sub {
                            my $incoming = shift;

                            if ($incoming->isa('IM::Engine::Incoming::IRC::Privmsg')) {
                                return $incoming->reply('PMing me! getting frisky are we?');
                            }

                            my $config     = $weakblock->param('config');
                            my $dispatcher = $weakblock->param('dispatcher');

                            my $message = $incoming->plaintext;

                            my $profile = $block->param('config')->site->{networks}{$block->param('profile')};

                            $block->param('schema')->add_message(
                                channel => $incoming->channel,
                                nick    => $incoming->sender->name,
                                message => $incoming->plaintext,
                            );

                            my ($prefix, $channel_data);
                            if ($incoming->isa('IM::Engine::Incoming::IRC::Channel')) {
                                $channel_data = first {
                                    lc($_->{name}) eq lc($incoming->channel)
                                } @{ $profile->{channels} };

                                $prefix = $profile->{prefix}
                                        || $channel_data->{prefix};
                            }

                            my $request = $incoming->plaintext;
                            my $response = undef;
                            if ($prefix) {
                                if (substr($request, 0, length($prefix)) eq $prefix) {
                                    $request = substr($request, length($prefix)) or return undef;

                                    my ($command, $args) = split ' ', $request, 2;
                                    my $dispatch = $dispatcher->dispatch($command);

                                    return undef unless $dispatch->has_matches;

                                    $response = $dispatch->run(
                                        $args,
                                        $incoming,
                                        $weakself->profile,
                                        $block->param('schema')
                                    );

                                    substr($response, 512) = q{} if $response && length($response) > 512;

                                    $block->param('schema')->log_response(
                                        channel  => $incoming->channel,
                                        response => $response,
                                    );
                                }
                                else {
                                    return undef;
                                }
                            }

                            return $incoming->reply($response);
                        },
                    }
                );
            },
            dependencies => wire_names(qw[config dispatcher schema profile]),
        );

        service timer => (
            lifecycle => 'Singleton',
            block     => sub {
                my $block = shift;
                weaken( my $weakblock = $block );
                AE::timer 0, 5, sub {
                    my $self = shift;

                    App::Dataninja::Util::tick($weakblock);
                }
            },
            dependencies => wire_names(qw[engine schema]),
        );

        service dispatcher => (
            class     => 'Path::Dispatcher',
            lifecycle => 'Singleton',
            block     => sub {
                my $block = shift;

                my @subrules;
                my $dispatcher = Path::Dispatcher->new();
                foreach my $command_class ($weakself->commands) {
                    Class::MOP::load_class($command_class);
                    my $command_meta = $command_class->meta;

                    foreach my $method ($command_meta->get_all_methods) {
                        next unless $method->meta->can('does_role');
                        next unless $method->meta->does_role('App::Dataninja::Meta::Role::Command');

                        my $method_name = $method->name;
                        $method_name =~ s/^__DATANINJA__//;

                        my $rule = Path::Dispatcher::Rule::Eq->new(
                            string => lc($method->name),
                            block  => $method->body,
                        );

                        $dispatcher->add_rule($rule);
                    }
                }

                $dispatcher;
            },
        );

        service config => (
            class     => 'App::Dataninja::Config',
            lifecycle => 'Singleton',
        );

        service app => (
            class      => 'App::Dataninja',
            lifecycle  => 'Singleton',
            dependencies => wire_names('engine'),
        );
    };

    $c->fetch('timer')->get; # get it started

    return $c;
}

=head1 NAME

Foo -

=head1 SYNOPSIS


=head1 DESCRIPTION


=cut

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 METHODS


=head1 AUTHOR

Jason May C<< <jason.a.may@gmail.com> >>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

