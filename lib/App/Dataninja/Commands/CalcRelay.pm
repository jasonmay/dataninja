package App::Dataninja::Commands::CalcRelay;
use App::Dataninja::Commands::OO;

=head1 NAME

App::Dataninja::Commands::CalcRelay - don't ask

=head1 COMMANDS

=over

=item * c B<calculation>

=back

=cut

command c => sub {
    my $match = shift;
    my $command_args = shift;
    return "!c $command_args";
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

