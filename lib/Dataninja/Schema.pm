package Dataninja::Schema;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;
use Dataninja::Config;

sub connect_with_defaults {
    my $class = shift;

    my $config = Dataninja::Config->new(@_);
    my $schema = $class->connect(
        'dbi:Pg:dbname=' . $config->main->{database}->{name},
        $config->main->{database}->{user},
        $config->main->{database}->{pass},
    );
}

__PACKAGE__->load_classes;

1;

