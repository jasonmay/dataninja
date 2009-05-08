package App::Dataninja::Bot::Plugin;
use Moose;
use DBIx::Class::Row;
extends 'Path::Dispatcher';

=head1 NAME

App::Dataninja::Bot::Plugin - base class for L<App::Dataninja> plugins

=head1 SYNOPSIS

  around 'command_setup' => sub {
      my $orig = shift;
      my $self = shift;
  
      $self->command(
          command => sub { "output" }
      );
  };

=head1 DESCRIPTION

App::Dataninja plugins use L<Module::Pluggable> as the backend.  This class contains
the necessary data that every plugin needs. It also contains some sugar
to improve readability.

=head1 METHODS

=head2 command

Usage: command(command => coderef)

This method adds a dispatcher rule. It is run in the C<command_setup> method.

=head2 command_setup

This method is meant to be overridden with the C<around> method modifier. It
is called at build time and is meant to contain all the command information.

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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
__END__

=head1 CURRENT PLUGINS

=over

=item * Botsnack

=item * CalcRelay

=item * Colors

=item * Daysuntil

=item * Echo

=item * Jobs

=item * Last

=item * Remind

=item * Seen

=item * Task

=item * Translating

=item * Twentyfour

=item * Twitter

=item * Unit

=item * Weather

=item * Weeksuntil

=back
