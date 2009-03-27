package Dataninja::Bot::Plugin::Foobar;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';

sub BUILD {
    my $self = shift;
    my $builder = Path::Dispatcher::Builder->new(dispatcher => $self);

    $builder->on(qr/^foo/ => sub {
        return $self->nick;
    });

    $builder->on(qr/^bar/ => sub {
        return $self->message;
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
