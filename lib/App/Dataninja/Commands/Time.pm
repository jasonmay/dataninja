package App::Dataninja::Commands::Time;
use Moose;
use DateTime;
extends 'App::Dataninja::Commands';

=head1 NAME

App::Dataninja::Commands::Time - get the time for a certain time zone

=head1 COMMANDS

=over

=item * time B<[time zone]>

This plugin gets the time for a certain time zonek.

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        time => sub {
            my $command_args = shift;
            return "please specify a timezone (Area/Location format)"
                unless $command_args;
            my $dt = eval { DateTime->now(time_zone => $command_args) };
            return "(eval) $@" if $@;
            return sprintf("%s %s", $dt->ymd, $dt->hms);
        }
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

