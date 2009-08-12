package App::Dataninja::Schema::Message;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_components(qw/PK::Auto InflateColumn Core/);
__PACKAGE__->table('messages');
__PACKAGE__->add_columns(
    id            => {data_type => 'integer', is_auto_increment => 1},
    network       => {data_type => 'varchar(256)'},
    message       => {data_type => 'text'},
    moment        => {data_type => 'timestamp'},
    channel       => {data_type => 'varchar(64)'},
    nick          => {data_type => 'varchar(64)'},
    stats_updated => {data_type => 'integer', default_value => 0},
    emotion       => {data_type => 'integer', default_value => 0},
);

sub parse_or_format {
    my ($which, $value, $obj) = @_;
    warn $obj->result_source->storage;
    my $dt_module = sprintf(
        'DateTime::Format::%s',
        $obj->result_source->storage->sqlt_type,
    );
    eval "require $dt_module";
    die $@ if $@;
    my $which_datetime = "${which}_datetime";
    return $dt_module->$which_datetime($value);
}

__PACKAGE__->inflate_column(
    moment => {
        inflate => sub {
            parse_or_format('parse', @_);
        },
        deflate => sub {
            parse_or_format('format', @_);
        }
    }
);

__PACKAGE__->set_primary_key(qw/id/);

1;
