package App::Dataninja::Schema::Entry;
use Moose::Role;

has body => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has network => (
    is       => 'ro',
    isa      => 'App::Dataninja::Schema::Network',
    required => 1,
);

has channel => (
    is       => 'ro',
    isa      => 'App::Dataninja::Schema::Channel',
    required => 1,
);

has properties => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

no Moose::Role;

1;
