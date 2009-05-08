package App::Dataninja::Bot::Dispatcher;
use Moose;
extends 'Path::Dispatcher';

=head1 NAME

App::Dataninja::Bot::Dispatcher - Class for building L<App::Dataninja>'s dispatcher

=head1 DESCRIPTION

This class constructs L<App::Dataninja>'s dispatcher from all the plugins in
L<App::Dataninja::Bot::Plugin>.

=head1 ATTRIBUTES

=head2 prefix

(C<Path::Dispatcher::PrefixRule>) Predicate for the dispatcher for handling the
initially symbolic prefix in front of commands, such as C<< ! >>, C<< @ >>,
or C<< # >>.

=head2 data_for_plugins

(L<App::Dataninja::Bot::Plugin>) This is a class that uses the plugin base to store
the data that the bot needs (message data, schema, etc.) to pass into each
plugin for rule dispatching.

=cut

has 'prefix' => (
    is       => 'ro',
    isa      => 'Path::Dispatcher::PrefixRule',
    required => 1,
);

has 'data_for_plugins' => (
    is       => 'ro',
    isa      => 'App::Dataninja::Bot::Plugin',
    required => 1,
);

has 'plugins' => (
    is      => 'rw',
    isa     => 'ArrayRef[Str]',
);

sub BUILD {
    my $self = shift;
    my $under = Path::Dispatcher::Rule::Under->new(
        predicate => $self->prefix,
        prefix    => 1,
        rules => [
            map {
                eval "require $_";
                die $@ if $@;
                my $dispatcher = $_->new;
                Path::Dispatcher::Rule::Dispatch->new(
                    dispatcher => $dispatcher,
                )
            } @{$self->plugins}
        ],
    );

    $self->add_rule($under);
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;

