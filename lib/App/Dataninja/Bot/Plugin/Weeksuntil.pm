package App::Dataninja::Bot::Plugin::Weeksuntil;
use Moose;
use DateTime::Format::Natural;
use DateTime::Format::Duration;
extends 'App::Dataninja::Bot::Plugin';

=head1 NAME

App::Dataninja::Bot::Plugin::Weeksuntil - displays weeks until whatever time you
provide

=head1 COMMANDS

=over

=item * weeksuntil B<day>

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        weeksuntil => sub {
            my $command_args = shift;
            my $parser = DateTime::Format::Natural->new;
            my $dt = $parser->parse_datetime($command_args);
            my $now = DateTime->now;

            my $diff = $dt->subtract_datetime($now);
            my $format_week = DateTime::Format::Duration->new(pattern => '%W');
            return sprintf('%s weeks!', int($format_week->format_duration($diff)));
        }
    );
};



__PACKAGE__->meta->make_immutable;
no Moose;

1;

