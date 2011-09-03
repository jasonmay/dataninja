package App::Dataninja::Model;
use Moose;

require App::Dataninja::Schema::Channel;
require App::Dataninja::Schema::Interjection;
require App::Dataninja::Schema::Message;
require App::Dataninja::Schema::Network;
require App::Dataninja::Schema::Nick;
require App::Dataninja::Schema::Reminder;

extends 'KiokuX::Model';

has '+dsn' => (
    default => 'dbi:SQLite:dbname=dataninja',
);

has '+extra_args' => (
    default => sub {
        my $do_if_message = sub {
            my ($sub) = @_;

            return sub {
                my $object = shift;
                return $sub->($object)
                    if $object->isa('App::Dataninja::Schema::Message');
            }
        };

        [
            create => 1,
            columns => [
                legacy_id => {
                    data_type   => 'integer',
                    is_nullible => 1,
                    extract     => $do_if_message->(sub { shift->legacy_id }),
                },
                bytes => {
                    data_type   => 'integer',
                    is_nullible => 1,
                    extract     => $do_if_message->(
                        sub { length($_[0]->body) }
                    ),
                },
                words => {
                    data_type   => 'integer',
                    is_nullible => 1,
                    extract     => $do_if_message->(
                        sub {
                            my @words = split ' ', shift->body;
                            return scalar(@words);
                        }
                    ),
                },
                year => {
                    data_type   => 'integer',
                    is_nullible => 1,
                    extract     => $do_if_message->(
                        sub { shift->said_at->year }
                    ),
                },
                month => {
                    data_type   => 'varchar',
                    is_nullible => 1,
                    extract     => $do_if_message->(
                        sub { shift->said_at->strftime('%Y-%m') }
                    ),
                },
                month_num => {
                    data_type   => 'integer',
                    is_nullible => 1,
                    extract     => $do_if_message->(
                        sub { shift->said_at->month }
                    ),
                },
                day => {
                    data_type   => 'varchar',
                    is_nullible => 1,
                    extract     => $do_if_message->(
                        sub { shift->said_at->ymd }
                    ),
                },
                day_num => {
                    data_type   => 'varchar',
                    is_nullible => 1,
                    extract     => $do_if_message->(
                        sub { shift->said_at->day }
                    ),
                },
            ],
        ]
    }
);

sub lookup_network {
    my $self = shift;
    my $name = shift;

    return $self->lookup("dn:network:$name");
}

sub lookup_nick {
    my $self    = shift;
    my $network = shift;
    my $name    = shift;

    return $self->lookup("dn:nick:$network:$name");
}

sub lookup_channel {
    my $self    = shift;
    my $network = shift;
    my $channel = shift;

    return $self->lookup("dn:channel:$network:$channel");
}

sub insert_message {
    my $self = shift;
    my %args = @_;

    my $channel = $self->lookup_channel($args{network}, $args{channel});
    my $nick = $self->lookup_nick($args{network}, $args{nick});

    my $message = App::Dataninja::Schema::Message->new(
        channel => $channel,
        nick    => $nick,
        body    => $args{body},
    );
}

no Moose;

1;

