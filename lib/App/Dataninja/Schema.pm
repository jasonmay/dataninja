package App::Dataninja::Schema;
use strict;
use warnings;
use base 'DBIx::Class::Schema';

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

__PACKAGE__->load_classes;

1;

