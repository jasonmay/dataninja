package App::Dataninja::Schema::Interjection;
use KiokuDB::Class;
with 'App::Dataninja::Schema::Interjection';

has interjected => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

no KiokuDB::Class;

1;
