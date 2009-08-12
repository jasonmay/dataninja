package App::Dataninja::Schema::NickStats;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('nick_stats');
__PACKAGE__->add_columns(
    id                    => {is_auto_increment => 1, data_type => 'bigint'},
    network               => {data_type => 'varchar(256)'},
    channel               => {data_type => 'varchar(64)'},
    nick                  => {data_type => 'varchar(64)'},
    year                  => {data_type => 'integer'},
    month                 => {data_type => 'integer'},
    day                   => {data_type => 'integer'},
    dow                   => {data_type => 'integer'},
    hour                  => {data_type => 'integer'},
    talking_to_bot        => {data_type => 'integer', default_value => 0},
    quantity              => {data_type => 'integer', default_value => 1},
);

__PACKAGE__->set_primary_key(qw/id/);

1;
