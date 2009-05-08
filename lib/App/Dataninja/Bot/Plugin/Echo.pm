package App::Dataninja::Bot::Plugin::Echo;
use Moose;
extends 'App::Dataninja::Bot::Plugin';

=head1 NAME

App::Dataninja::Bot::Plugin::Echo - the bot merely echos what you put, for random utility

=head1 COMMANDS

=over

=item * echo B<message>

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        echo => sub {
            my $command_args = shift;
            return $command_args;
        }
    )
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

