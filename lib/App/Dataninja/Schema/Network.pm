package App::Dataninja::Schema::Network;
use KiokuDB::Class;
with 'App::Dataninja::Schema::ID';

sub id {
    my $self = shift;
    return 'network:' . $self->name;
}

has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has secret => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has server => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has port => (
    is      => 'ro',
    isa     => 'Int',
    default => 6667,
);

no KiokuDB::Class;

1;
