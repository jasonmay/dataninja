package App::Dataninja::Schema::Message::Aggregates;
use KiokuDB::Class;
use KiokuDB::Util 'set';

has attr => (
    is  => 'ro',
    isa => 'Str',
);

no KiokuDB::Class;

1;
