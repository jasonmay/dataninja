package App::Dataninja::Commands::Colors;
use App::Dataninja::Commands::OO;

=head1 NAME

App::Dataninja::Commands::Colors - display list of colors corresponding to ASCII
values

=head1 COMMANDS

=over

=item * colors

=back

=cut

command colors => sub {
    return join q{ },
    map {
        "\e[0;3${_}m${_}\e[1;3${_}m${_}\e[0m"
    } (0 .. 7);
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

