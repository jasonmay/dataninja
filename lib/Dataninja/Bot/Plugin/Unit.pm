package Dataninja::Bot::Plugin::Unit;
use Moose;
use WWW::Google::Calculator;
extends 'Dataninja::Bot::Plugin::Base';

my @history;
around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;


    my $unit_code = sub {
        my $command_args = shift;

        my $calc = WWW::Google::Calculator->new;
        return eval {
            my $modified_input = $command_args;
            $modified_input
                =~ s/\$(\d)/(@history > $1) ? $history[$1] : \$$1/eg;
            warn $modified_input;

            my $ret = $calc->calc($modified_input);
            if (defined $ret) {
                if ($ret =~ /^.*=\s*(.*)$/) {
                    unshift @history, $1;
                    warn join ', ' => @history;
                }
                return $ret;
            }
            return "huh?";
        } unless $@;
        return $@;
    };

    $self->command(unit => $unit_code);
    $self->command(u    => $unit_code);
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

