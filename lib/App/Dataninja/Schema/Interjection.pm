package App::Dataninja::Schema::Interjection;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('interjections');
__PACKAGE__->add_columns(
    id          => {is_auto_increment => 1, data_type => 'integer'},
    message     => {data_type => 'text'},
    network     => {data_type => 'varchar(256)'},
    channel     => {data_type => 'varchar(64)'},
    interjected => { data_type     => 'integer', default_value => 0 },
);
__PACKAGE__->set_primary_key(qw/id/);

1;
