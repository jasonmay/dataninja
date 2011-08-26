package App::Dataninja::Schema::Nick;
use KiokuDB::Class;

has name => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has network => (
    is       => 'ro',
    isa      => 'App::Dataninja::Schema::Network',
    required => 1,
);

has location => (
    is  => 'rw',
    isa => 'Str',
);

no KiokuDB::Class;

1;
