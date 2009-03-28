package Dataninja::Bot::Plugin::Task;
use Moose;
use Net::Hiveminder;
extends 'Dataninja::Bot::Plugin::Base';

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        task => sub {
            my $command_args = shift;
            my $hm = Net::Hiveminder->new(use_config => 1);

            (my $task = $1) =~ s/\[.+?\]//g;
            my $priorities_munged = 0;

            warn "TASK: $task";
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

