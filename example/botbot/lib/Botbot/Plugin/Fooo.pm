package Botbot::Plugin::Fooo;
use Moose;
extends 'Dataninja::Bot::Plugin';

=head1 NAME

Dataninja::Plugin::Echo - the bot merely echos what you put, for random utility

=head1 COMMANDS

=over

=item * echo B<message>

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        fooo => sub {
            my $command_args = lc(shift);
            $command_args =~ y/aeiou/ioaue/;
            return $command_args;
        }
    )
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

