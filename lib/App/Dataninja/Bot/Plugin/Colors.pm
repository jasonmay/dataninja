package App::Dataninja::Bot::Plugin::Colors;
use Moose;
extends 'App::Dataninja::Bot::Plugin';

=head1 NAME

App::Dataninja::Bot::Plugin::Colors - display list of colors corresponding to ASCII
values

=head1 COMMANDS

=over

=item * colors

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        colors => sub {
            return join q{ },
            map {
                "\e[0;3${_}m${_}\e[1;3${_}m${_}\e[0m"
            } (0 .. 7);
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

