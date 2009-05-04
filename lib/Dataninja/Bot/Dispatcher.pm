package Dataninja::Bot::Dispatcher;
use Moose;
use Module::Pluggable
    search_path => 'Dataninja::Bot::Plugin',
    sub_name    => 'plugins',
    require     => 1;
extends 'Dataninja::Bot::Plugin';

=head1 NAME

Dataninja::Bot::Dispatcher - Class for building Dataninja's dispatcher

=head1 DESCRIPTION

This class constructs Dataninja's dispatcher from all the plugins in
L<Dataninja::Bot::Plugin>.

=head1 ATTRIBUTES

=head2 prefix

(L<Path::Dispatcher::PrefixRule>) Predicate for the dispatcher for handling the
initially symbolic prefix in front of commands, such as C<<!>>, C<<@>>,
or C<<#>>.

=head2 schema

(L<Dataninja::Schema>) This is just a copy of the database schema for plugin
access.

=cut

has 'prefix' => (
    is       => 'ro',
    isa      => 'Path::Dispatcher::PrefixRule',
    required => 1,
);

has 'schema' => (
    is       => 'ro',
    isa      => 'Dataninja::Schema',
    required => 1,
);

sub BUILD {
    my $self = shift;
    my $under = Path::Dispatcher::Rule::Under->new(
        predicate => $self->prefix,
        prefix    => 1,
        rules => [
            map {
                my $dispatcher = $_->new(
                    message_data => $self->message_data,
#                    nick      => $self->nick,
#                    channel => $self->channel,
#                    network => $self->network,
#                    moment  => $self->moment,
#                    message => $self->message,
                    schema   => $self->schema,
                );
                Path::Dispatcher::Rule::Dispatch->new(
                    dispatcher => $dispatcher,
                )
            } $self->plugins
        ],
    );

    $self->add_rule($under);
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;

