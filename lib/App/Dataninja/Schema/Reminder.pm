package App::Dataninja::Schema::Reminder;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto InflateColumn Core/);
__PACKAGE__->table('reminders');
__PACKAGE__->add_columns(
    id          => {is_auto_increment => 1, data_type => 'integer'},
    moment      => {data_type => 'timestamp'},
    description => {data_type => 'text'},
    remindee    => {data_type => 'varchar(64)'},
    maker       => {data_type => 'varchar(64)'},
    made        => {data_type => 'timestamp'},
    channel     => {data_type => 'varchar(64)'},
    network     => {data_type => 'varchar(256)'},

    reminded    => { data_type => 'integer', default_value => 0 },
    canceled    => { data_type => 'integer', default_value => 0 },
);

sub parse_or_format {
    my ($which, $value, $obj) = @_;
    my $which_datetime = "${which}_datetime";
    return DateTime::Format::Pg->$which_datetime($value);
}

__PACKAGE__->inflate_column(
    moment => {
        inflate => sub { parse_or_format('parse', @_);  },
        deflate => sub { parse_or_format('format', @_); }
    }
);

__PACKAGE__->set_primary_key(qw/id/);

1;
