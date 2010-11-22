package App::Dataninja::Commands::Daysuntil;
use App::Dataninja::Commands::OO;
use DateTime::Format::Natural;

=head1 NAME

App::Dataninja::Commands::Daysuntil - displays days until whatever time you
provide

=head1 COMMANDS

=over

=item * daysuntil B<day>

=back

=cut

command daysuntil => sub {
    my $match = shift;
    my $command_args = shift;
    return "until when?" unless defined $command_args;
    my $parser = DateTime::Format::Natural->new;
    my $dt = $parser->parse_datetime($command_args);
    my $now = DateTime->now;

    my $seconds_diff = $dt->epoch - $now->epoch;
    return "it's too late for that :(" if $seconds_diff < 0;

    my $days_diff = int($seconds_diff/86400);

    return "$days_diff days!";
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

