package App::Dataninja::Commands::Seen;
use App::Dataninja::Commands::OO;
use DateTime::Format::Pg;
use DateTime::Duration;
use DateTime::Format::Human::Duration;

=head1 NAME

App::Dataninja::Commands::Seen - the bot tells you when someone was last seen

=head1 COMMANDS

=over

=item * seen B<nick>

=back

=cut

my $dur = DateTime::Format::Human::Duration->new;
command seen => sub {
    my $match        = shift;
    my $command_args = shift;
    my ($incoming, $profile, $schema) = @_;
    my $nick         = lc $command_args;
    return "seen who?" unless $nick;

    return "heh, that's you!" if $nick eq lc($incoming->sender->name);

    my $latest_message = $schema->latest_message_of($nick)
        or return "haven't seen anyone who goes by '$nick'";

    my $formatted_moment  = $dur->format_duration_between(
        $latest_message->moment,
        DateTime->now,
    );

    return
        sprintf(
            "%s ago: <%s> %s",
            $formatted_moment,
            $latest_message->nick,
            $latest_message->message
        );
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

