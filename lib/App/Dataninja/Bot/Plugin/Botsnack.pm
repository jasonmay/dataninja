package App::Dataninja::Bot::Plugin::Botsnack;
use Moose;
extends 'App::Dataninja::Bot::Plugin';

=head1 NAME

App::Dataninja::Bot::Plugin::Botsnack - bot gets a snack for making you happy :)

=head1 COMMANDS

=over

=item * botsnack

You give the bot a botsnack, and he responds with gratitude.

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        botsnack => sub { "sweet, thanks! :)" }
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

