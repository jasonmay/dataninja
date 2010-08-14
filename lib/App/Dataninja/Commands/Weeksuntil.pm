package App::Dataninja::Commands::Weeksuntil;
use App::Dataninja::Commands::OO;
use DateTime::Format::Natural;
use DateTime::Format::Duration;

=head1 NAME

App::Dataninja::Commands::Weeksuntil - displays weeks until whatever time you
provide

=head1 COMMANDS

=over

=item * weeksuntil B<day>

=back

=cut

command weeksuntil => sub {
    my $command_args = shift;
    return "until when?" unless defined $command_args;
    my $parser = DateTime::Format::Natural->new;
    my $dt = $parser->parse_datetime($command_args);
    my $now = DateTime->now;

    my $diff = $dt->subtract_datetime($now);
    my $format_week = DateTime::Format::Duration->new(pattern => '%W');
    return sprintf('%s weeks!', int($format_week->format_duration($diff)));
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

