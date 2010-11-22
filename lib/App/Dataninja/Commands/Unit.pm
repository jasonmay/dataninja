package App::Dataninja::Commands::Unit;
use App::Dataninja::Commands::OO;
use WWW::Google::Calculator;

=head1 NAME

App::Dataninja::Commands::Unit - the bot can do unit conversion for you

=head1 COMMANDS

=over

=item * unit B<conversion>

The bot talks to Google Calculator (using L<WWW::Google::Calculator> to do the
unit conversion for you. You also have access to result history, particularly
the last ten results (C<$0> to
C<$9>).

=item * u B<conversion>

This is an alias for B<unit>.

=back

=cut

{
    my @history;

    command ['u', 'unit'] => sub {
        my $match = shift;
        my $command_args = shift;

        my $calc = WWW::Google::Calculator->new;
        return eval {
            my $modified_input = $command_args;
            $modified_input
                =~ s/\$(\d)/(@history > $1) ? $history[$1] : \$$1/eg;

            my $ret = $calc->calc($modified_input);
            if (defined $ret) {
                if ($ret =~ /^.*=\s*(.*)$/) {
                    unshift @history, $1;
                }
                return $ret;
            }
            return "huh?";
        } unless $@;
        return "(eval) $@";
    };
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;

