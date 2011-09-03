package App::Dataninja::Schema::Message;
use KiokuDB::Class;
use DateTime;

with 'App::Dataninja::Schema::Entry';

has nick => (
    is       => 'ro',
    isa      => 'App::Dataninja::Schema::Nick',
    required => 1,
);

has channel => (
    is       => 'ro',
    isa      => 'App::Dataninja::Schema::Channel',
    required => 1,
);

has said_at => (
    is      => 'ro',
    isa     => 'DateTime',
    default => sub { DateTime->now },
);

has legacy_id => (
    is      => 'ro',
    isa     => 'Int',
);

no KiokuDB::Class;

1;
