package App::Dataninja::Commands::Echo;
use App::Dataninja::Commands::OO;

=head1 NAME

App::Dataninja::Commands::Echo - the bot merely echos what you put, for random utility

=head1 COMMANDS

=over

=item * echo B<message>

=back

=cut

command echo => sub {
        my $command_args = shift;
        return $command_args;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

