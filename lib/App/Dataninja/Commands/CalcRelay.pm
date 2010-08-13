package App::Dataninja::Commands::CalcRelay;
use Moose;
extends 'App::Dataninja::Commands';

=head1 NAME

App::Dataninja::Commands::CalcRelay - don't ask

=head1 COMMANDS

=over

=item * c B<calculation>

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        c => sub {
            my $command_args = shift;
            return "!c $command_args";
        }
    );
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

