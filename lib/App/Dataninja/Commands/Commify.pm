package App::Dataninja::Commands::Commify;
use App::Dataninja::Commands::OO;
use Number::Format qw(:subs);

=head1 NAME

App::Dataninja::Commands::Commify - add commas to numbers

=head1 COMMANDS

=over

=item * commify B<number>

When a user gives dataninja a number using this command, dataninja outputs
the number with commas put in the right places.

=back

=cut

command commify => sub {
    my $match = shift;
    my $command_arg = shift;
    my $output =  eval { format_number $command_arg };
    return "(eval) $@" if $@;
    return $output;
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

