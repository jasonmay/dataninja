package Dataninja::Bot::Plugin::Base;
use Moose;
extends 'Path::Dispatcher';

# information of the caller
has nick => (
    is => 'ro',
    isa => 'Str',
);

has channel => (
    is => 'ro',
    isa => 'Str',
);

has network => (
    is => 'ro',
    isa => 'Str',
);

has moment => (
    is => 'ro',
    isa => 'DateTime',
);

has message => (
    is => 'ro',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

