package Dataninja::Bot::Plugin::CalcRelay;
use Moose;
extends 'Dataninja::Bot::Plugin::Base';

=head1 NAME

Dataninja::Bot::Plugin::CalcRelay - don't ask

=head1 COMMANDS

=item * c B<calculation>

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

