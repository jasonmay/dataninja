package App::Dataninja::Dispatcher;
use Moose;
extends 'Path::Dispatcher';

=head1 NAME

App::Dataninja::Bot::Dispatcher - Class for building L<App::Dataninja>'s dispatcher

=head1 DESCRIPTION

This class constructs L<App::Dataninja>'s dispatcher from all the plugins in
L<App::Dataninja::Bot::Plugin>.

=head1 ATTRIBUTES

=head2 data_for_plugins

(L<App::Dataninja::Bot::Plugin>) This is a class that uses the plugin base to store
the data that the bot needs (message data, schema, etc.) to pass into each
plugin for rule dispatching.

=cut

sub BUILD {
    my $self = shift;
    my $rule = Path::Dispatcher::Rule::Under->new(
        rules => [
            map {
                Class::MOP::load_class($_);
                my $dispatcher = $_->new;
                Path::Dispatcher::Rule::Dispatch->new(
                    dispatcher => $dispatcher,
                )
            } @{$self->plugins}
        ],
    );

    $self->add_rule($rule);

    foreach my $plugin (@{$self->plugins}) {
        foreach my $rule ($plugin->extra_primary_dispatcher_rules) {
            $self->add_rule($rule);
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

