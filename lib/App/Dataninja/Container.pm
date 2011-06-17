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
    is      => 'rw',
    isa     => 'Bread::Board::Container',
    builder => '_build__container',
    handles => ['fetch'],
    lazy    => 1,
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

        service storage => (
            class        => 'App::Dataninja::Storage',
            lifecycle    => 'Singleton',
            dependencies => wire_names(qw[profile config]),
        );

        service engine => (
            class     => 'App::Dataninja::Engine',
            lifecycle => 'Singleton',
            dependencies => wire_names(qw[config dispatcher storage profile]),
        );

        service timer => (
            lifecycle => 'Singleton',
            block     => sub {
                my $block = shift;
                weaken( my $weakblock = $block );
                AE::timer 0, 5, sub {
                    my $self = shift;

                    eval { App::Dataninja::Util::tick($weakblock); };
                    warn "!!! $@" if $@;
                }
            },
            dependencies => wire_names(qw[engine storage]),
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

