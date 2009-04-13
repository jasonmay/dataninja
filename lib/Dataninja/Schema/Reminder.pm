package Dataninja::Schema::Reminder;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('reminders');
__PACKAGE__->add_columns(qw/id moment description remindee maker channel network reminded canceled/);
__PACKAGE__->set_primary_key(qw/id/);
