package Dataninja::Schema::Person;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('people');
__PACKAGE__->add_columns(qw/id/);
__PACKAGE__->set_primary_key(qw/id/);

1;
