#!/usr/bin/env perl
package App::Dataninja::Container;
use Moose;
use Bread::Board;
use App::Dataninja::Dispatcher;
use App::Dataninja::Schema;
use IM::Engine;
use List::Util qw(first);

use Module::Pluggable
    search_path => ['App::Dataninja::Commands'],
    sub_name    => 'commands',
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
                my $schema = App::Dataninja::Schema->connect('dbi:SQLite:etc/dataninja.sqlite');
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
                                profile => $block->param('profile'),
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

                                    my $dispatch = $dispatcher->dispatch($request);

                                    return undef unless $dispatch->has_matches;

                                    (my $args = $request) =~ s/^\S+(?:\s+)?//;
                                    warn $block->param('schema');

                                    $response = $dispatch->run(
                                        $args,
                                        $incoming,
                                        $weakself->profile,
                                        $block->param('schema')
                                    );

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

#        service timer => (
#            lifecycle => 'Singleton',
#            block     => sub { warn "no" },
#        );
#
        service dispatcher => (
            class     => 'Path::Dispatcher',
            lifecycle => 'Singleton',
            block     => sub {
                my $block = shift;

                my @subrules;
                my $dispatcher = Path::Dispatcher->new();
                foreach my $command_class ($weakself->commands) {
                    Class::MOP::load_class($command_class);
                    my $subdispatcher = $command_class->new();

                    # I *really* have to do something about this
                    $dispatcher->add_rule($_) for $subdispatcher->rules;
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

