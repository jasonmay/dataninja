package Dataninja::Bot::Plugin::Base;
use Moose;
use DBIx::Class::Row;
extends 'Path::Dispatcher';


# information of the caller
has message_data => (
    is       => 'ro',
    isa      => 'DBIx::Class::Row',
    required => 1,
);

#has nick => (
#    is => 'ro',
#    isa => 'Str',
#    required => 1,
#);
#
#has channel => (
#    is => 'ro',
#    isa => 'Str',
#    required => 1,
#);
#
#has network => (
#    is => 'ro',
#    isa => 'Str',
#    required => 1,
#);
#
#has moment => (
#    is => 'ro',
#    isa => 'DateTime',
#    required => 1,
#);
#
#has message => (
#    is => 'ro',
#    isa => 'Str',
#    required => 1,
#);

has schema => (
    is => 'rw',
    isa => 'Dataninja::Schema',
    required => 1,
);

sub BUILD {
    my $self = shift;
    $self->command_setup;
}

sub command {
    my $self = shift;
    my $command = shift;
    my $code = shift;
    $self->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr/^$command(?:\s+(.+))?$/,
            block => $code,
        )
    );
}

sub command_setup {
    my $self = shift;
    my $code = shift;
}

# sugar for returning DBIC resultsets
sub rs {
    my $self = shift;
    my $schema_class = shift;

    return $self->schema->resultset($schema_class);
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;
