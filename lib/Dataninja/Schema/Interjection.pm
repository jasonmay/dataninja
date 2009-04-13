package Dataninja::Schema::Interjection;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('areas');
__PACKAGE__->add_columns(qw/id message interjected network channel/);
__PACKAGE__->set_primary_key(qw/id/);
