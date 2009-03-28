package Dataninja::Bot::Plugin::Base;
use Moose;
extends 'Path::Dispatcher';

# information of the caller
has nick => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has channel => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has network => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has moment => (
    is => 'ro',
    isa => 'DateTime',
    required => 1,
);

has message => (
    is => 'ro',
    isa => 'Str',
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
            regex => qr/^$command(?:\s+)?(.+)?$/,
            block => $code,
            prefix => 1,
        )
    );
}

sub command_setup {
    my $self = shift;
    my $code = shift;
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;
