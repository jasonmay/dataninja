package App::Dataninja::Schema;
use strict;
use warnings;
use base qw/DBIx::Class::Schema/;
use App::Dataninja::Config;

=head1 NAME

App::Dataninja::Schema - L<DBIx::Class> schema for the App::Dataninja database

=head1 METHODS

=head2 connect_with_defaults

This method wraps around C<connect> and connects with the database
configuration provided by L<App::Dataninja::Config>. It takes in the same
arguments L<App::Dataninja::Config> does.

See L<DBIx::Class::Schema> for other methods.

=head1 TABLES

=over

=item * Area

=item * Interjection

=item * Message

=item * Nick

=item * Reminder

=back

=cut

sub connect_with_defaults {
    my $class = shift;

    my $config = App::Dataninja::Config->new(@_);
    my $schema = $class->connect(
        sprintf(
            'dbi:%s:dbname=%s',
            $config->main->{database}->{driver},
            $config->main->{database}->{name},
        ),
        $config->main->{database}->{user},
        $config->main->{database}->{pass},
    );

    return $schema;
}

__PACKAGE__->load_classes;

1;

