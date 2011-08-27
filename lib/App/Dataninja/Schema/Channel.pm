package App::Dataninja::Schema::Channel;
use KiokuDB::Class;
with 'App::Dataninja::Schema::ID';

sub id {
    my $self = shift;
    return sprintf('channel:%s:%s', $self->network->name, $self->name);
}

has network => (
    is       => 'rw',
    isa      => 'App::Dataninja::Schema::Network',
    required => 1,
);

has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has secret => (
    is  => 'rw',
    isa => 'Bool',
    default => 0,
);

no KiokuDB::Class;

1;
