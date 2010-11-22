package App::Dataninja::Commands::Time;
use App::Dataninja::Commands::OO;
use DateTime;

=head1 NAME

App::Dataninja::Commands::Time - get the time for a certain time zone

=head1 COMMANDS

=over

=item * time B<[time zone]>

This plugin gets the time for a certain time zonek.

=back

=cut

command time => sub {
    my $match = shift;
    my $command_args = shift;
    return "please specify a timezone (Area/Location format)"
        unless $command_args;
    my $dt = eval { DateTime->now(time_zone => $command_args) };
    return "(eval) $@" if $@;
    return sprintf("%s %s", $dt->ymd, $dt->hms);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

