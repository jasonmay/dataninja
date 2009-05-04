package Dataninja::Bot::Plugin::Base;
use Moose;
use DBIx::Class::Row;
extends 'Path::Dispatcher';

=head1 NAME

Dataninja::Bot::Plugin::Base - base class for Dataninja plugins

=head1 DESCRIPTION

This class contains the necessary data that every plugin needs. It also
contains some sugar for readability.

=head1 SYNOPSIS

  around 'command_setup' => sub {
      my $orig = shift;
      my $self = shift;
  
      $self->command(
          command => sub { "sweet, thanks! :)" }
      );
  };

=head1 ATTRIBUTES

=head2 message_data

(L<DBIx::Class::Row>) The row returned by the schema containing the data
about user's message to call the command for the plugin.

=head2 schema

(L<Dataninja::Schema>) A reference to the main Dataninja database schema

=cut

has message_data => (
    is       => 'ro',
    isa      => 'DBIx::Class::Row',
    required => 1,
);

has schema => (
    is => 'rw',
    isa => 'Dataninja::Schema',
    required => 1,
);

=head1 METHODS

=head2 command

Usage: command(command => coderef)

This method adds a dispatcher rule. It is run in the C<command_setup> method.

=head2 command_setup

This method is meant to be overridden with the C<around> method modifier. It
is called at build time and is meant to contain all the command information.

=head2 rs

Usage: rs(schema_class)

This method is sugar for C<<schema->resultset(schema_class)>> which is
normally provided by the L<DBIx::Class:Schema> object C<schema>.

=cut

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

sub rs {
    my $self = shift;
    my $schema_class = shift;

    return $self->schema->resultset($schema_class);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
