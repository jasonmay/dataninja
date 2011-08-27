package App::Dataninja::Schema::ID;
use Moose::Role;

with 'KiokuDB::Role::ID';

sub kiokudb_object_id { 'dn:' . shift->id }

requires 'id';

no Moose::Role;

1;
