package App::Dataninja::Schema::Channel;
use KiokuDB::Class;

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
