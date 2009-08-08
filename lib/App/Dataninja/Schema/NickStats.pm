package App::Dataninja::Schema::NickStats;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('nick_stats');
__PACKAGE__->add_columns(
    id              => {is_auto_increment => 1, data_type => 'integer'},
    network         => {},
    channel         => {},
    nick            => {},
    year            => {},
    month           => {},
    day             => {},
    dow             => {},
    hour            => {},
    stats_updated   => {default => 0, data_type => 'integer'},
);

__PACKAGE__->set_primary_key(qw/id/);

1;
