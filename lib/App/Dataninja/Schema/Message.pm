package App::Dataninja::Schema::Message;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core/);
__PACKAGE__->table('messages');
__PACKAGE__->add_columns(
    id          => {is_auto_increment => 1, data_type => 'integer'},
    nick    => {},
    message => {},
    moment  => {},
    channel => {},
    network => {},
);
__PACKAGE__->set_primary_key(qw/id/);

1;
