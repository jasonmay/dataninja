package App::Dataninja::Commands::Last;
use App::Dataninja::Commands::OO;
use App::Nopaste 'nopaste';

=head1 NAME

App::Dataninja::Commands::Last - you tell the bot show many of the last N messages you wan to see

=head1 COMMANDS

=over

=item * last B<#>

The bot nopastes the last B<#> lines and shows it to you.

=back

=cut

sub _line {
    my ($timestamp, $nick, $message) = @_;
    return sprintf("%s <%s> %s", $timestamp, $nick, $message);
}

command last => sub {
    my $command_args = shift;
    my $incoming = shift;
    my $profile = shift;
    my $schema       = shift;

    my $rows = defined $command_args ? $command_args : 25;
    $rows = 200 if $rows > 200;
    $rows = 10 if $rows < 10;

    my @messages = $schema->resultset('Message')->search(
        {
            network => $profile,
            channel => $incoming->channel,
        },
        { rows => $rows, order_by => 'moment desc'}
    );

    return "Last $rows lines: " . nopaste(
        join qq{\n} =>
        map {
            _line($_->moment, $_->nick, $_->message)
        } reverse @messages
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

