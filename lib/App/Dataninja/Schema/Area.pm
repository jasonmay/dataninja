package App::Dataninja::Schema::Area;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('areas');
__PACKAGE__->add_columns(
    id       => {is_auto_increment => 1, data_type => 'integer'},
    location => {data_type => 'varchar(256)'},
    nick     => {data_type => 'varchar(64)'},
    network  => {data_type => 'varchar(256)'},
);
__PACKAGE__->set_primary_key(qw/id/);

1;
