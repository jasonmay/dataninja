package App::Dataninja::Commands::Botsnack;
use App::Dataninja::Commands::OO;

=head1 NAME

App::Dataninja::Commands::Botsnack - bot gets a snack for making you happy :)

=head1 COMMANDS

=over

=item * botsnack

You give the bot a botsnack, and he responds with gratitude.

=back

=cut

warn __PACKAGE__->can('command');

command(botsnack => sub { "sweet, thanks! :)" });

__PACKAGE__->meta->make_immutable;

1;

