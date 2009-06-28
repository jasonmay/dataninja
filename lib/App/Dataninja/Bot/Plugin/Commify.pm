package App::Dataninja::Bot::Plugin::Commify;
use Moose;
extends 'App::Dataninja::Bot::Plugin';

use Number::Format qw(:subs);

=head1 NAME

App::Dataninja::Bot::Plugin::Commify - add commas to numbers

=head1 COMMANDS

=over

=item * commify B<number>

When a user gives dataninja a number using this command, dataninja outputs
the number with commas put in the right places.

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        commify => sub {
            my $command_arg = shift;
            my $output =  eval { format_number $command_arg };
            return "(eval) $@" if $@;
            return $output;
        }
    );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

