package Dataninja::Bot::Plugin::Base;
use Moose;
use Path::Dispatcher::Builder;
extends 'Path::Dispatcher';

# information of the caller
has nick => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has channel => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has network => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has moment => (
    is => 'ro',
    isa => 'DateTime',
    required => 1,
);

has message => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has builder => (
    is => 'ro',
    isa => 'Path::Dispatcher::Builder',
    default => sub { Path::Dispatcher::Builder->new(dispatcher => shift) },
);

sub BUILD {
    my $self = shift;
    $self->command_setup;
}

sub command {
    my $self = shift;
    my $command = shift;
    my $code = shift;
    $self->builder->on(qr/^$command/ => $code);
}

sub command_setup {
    my $self = shift;
    my $code = shift;
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;

