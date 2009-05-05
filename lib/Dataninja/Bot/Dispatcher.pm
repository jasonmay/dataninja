package Dataninja::Bot::Dispatcher;
use Moose;
use Module::Pluggable
    search_path => 'Dataninja::Bot::Plugin',
    sub_name    => 'plugins',
    require     => 1;
extends 'Path::Dispatcher';

=head1 NAME

Dataninja::Bot::Dispatcher - Class for building Dataninja's dispatcher

=head1 DESCRIPTION

This class constructs Dataninja's dispatcher from all the plugins in
L<Dataninja::Bot::Plugin>.

=head1 ATTRIBUTES

=head2 prefix

(L<Path::Dispatcher::PrefixRule>) Predicate for the dispatcher for handling the
initially symbolic prefix in front of commands, such as C<< ! >>, C<< @ >>,
or C<< # >>.

=head2 data_for_plugins

(L<Dataninja::Bot::Plugin>) This is a class that uses the plugin base to store
the data that Dataninja needs (message data, schema, etc.) to pass into each
plugin for rule dispatching.

=cut

has 'prefix' => (
    is       => 'ro',
    isa      => 'Path::Dispatcher::PrefixRule',
    required => 1,
);

has 'data_for_plugins' => (
    is       => 'ro',
    isa      => 'Dataninja::Bot::Plugin',
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
                    message_data => $self->data_for_plugins->message_data,
                    schema   => $self->data_for_plugins->schema,
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

