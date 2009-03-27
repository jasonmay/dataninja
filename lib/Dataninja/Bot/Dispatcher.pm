package Dataninja::Bot::Dispatcher;
use Moose;
use Module::Pluggable
    search_path => 'Dataninja::Bot::Plugin',
    sub_name    => 'plugins',
    require     => 1;
extends 'Path::Dispatcher';

has 'prefix' => (
    is       => 'ro',
    isa      => 'Path::Dispatcher::PrefixRule',
    required => 1,
);

sub BUILD {
    my $self = shift;

    my $under = Path::Dispatcher::Rule::Under->new(
        predicate => $self->prefix,
        rules => [
            map {
                Path::Dispatcher::Rule::Dispatch->new(dispatcher => $_->dispatcher);
            } $self->plugins
        ],
    );

    $self->add_rule($under);
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;

