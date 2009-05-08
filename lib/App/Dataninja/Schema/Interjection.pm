package App::Dataninja::Schema::Interjection;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto Core InflateColumn::Boolean/);
__PACKAGE__->table('interjections');
__PACKAGE__->false_is([qw/f false/]);
__PACKAGE__->true_is([qw/t true/]);
__PACKAGE__->add_columns(
    id          => {is_auto_increment => 1, data_type => 'integer'},
    message     => {},
    network     => {},
    channel     => {},
    interjected => {
        is_boolean    => 1,
        data_type     => 'integer',
        default_value => 0,
    },
);
__PACKAGE__->set_primary_key(qw/id/);

1;
