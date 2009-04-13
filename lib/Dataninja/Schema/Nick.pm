package Dataninja::Schema::Nick;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('nicks');
__PACKAGE__->add_columns(qw/id name network/);
__PACKAGE__->set_primary_key(qw/id/);
