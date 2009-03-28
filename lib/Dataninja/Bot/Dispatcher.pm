package Dataninja::Bot::Dispatcher;
use Moose;
use Module::Pluggable
    search_path => 'Dataninja::Bot::Plugin',
    except      => 'Dataninja::Bot::Plugin::Base',
    sub_name    => 'plugins',
    require     => 1;
extends 'Dataninja::Bot::Plugin::Base';

has 'prefix' => (
    is       => 'ro',
    isa      => 'Path::Dispatcher::PrefixRule',
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
                    nick    => $self->nick,
                    channel => $self->channel,
                    network => $self->network,
                    moment  => $self->moment,
                    message => $self->message,
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

