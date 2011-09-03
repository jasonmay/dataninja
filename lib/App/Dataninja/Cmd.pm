package App::Dataninja::Cmd;
use Moose;
use App::Dataninja;

with 'MooseX::Getopt';

has network => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has bot => (
    is      => 'ro',
    isa     => 'App::Dataninja',
    lazy    => 1,
    traits  => ['NoGetopt'],
    handles => ['run'],

    default => sub { App::Dataninja->new(network => shift->network) },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
