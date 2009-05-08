package App::Dataninja::Bot::Plugin::Task;
use Moose;
use Net::Hiveminder;
extends 'App::Dataninja::Bot::Plugin';

=head1 NAME

App::Dataninja::Bot::Plugin::Task - add task to your hiveminder that pertains to App::Dataninja

=head1 COMMANDS

=over

=item * task B<description>

This command adds the task, strips any priority manipulation and slaps on the tag B<irc_dataninja>.

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        task => sub {
            my $command_args = shift;
            my $hm = Net::Hiveminder->new(use_config => 1);

            (my $task = $1) =~ s/\[.+?\]//g;
            my $priorities_munged = 0;

            $priorities_munged = 1 if $task =~ /!/ || $task =~ /^[+-]/;
            $task =~ y/!//d;
            $task =~ s/^[+-]*//g;
            my $warnings = "";
            $warnings = " (warning: priority modification detected and stripped)"
            if $priorities_munged;
            return "task: " . $hm->create_task("$task [irc_dataninja]")->{record_locator}
            . $warnings;
        }
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

