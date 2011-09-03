package App::Dataninja::Schema::Interjection;
use KiokuDB::Class;
use DateTime;

with 'App::Dataninja::Schema::Entry';

has channel => (
    is  => 'ro',
    isa => 'App::Dataninja::Schema::Channel',
);

has said_at => (
    is       => 'ro',
    isa      => 'DateTime',
    default  => sub { DateTime->now },
);

has interjected => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

no KiokuDB::Class;

1;
