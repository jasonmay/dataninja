package App::Dataninja::Schema::Entry;
use Moose::Role;

has body => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has properties => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

no Moose::Role;

1;
