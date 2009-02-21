#!/usr/bin/env perl
package Dataninja::Bot::Command::Add;
use strict;
use warnings;
use base 'Dataninja::Bot::Command';
use List::MoreUtils qw(any);

sub pattern { qr|^#add\s+(\w+)| }
sub run {
    my (undef, $rules) = @_;

    return "... uhh that's already there, dude"
        if any { lc $_->{name} eq lc $1 } @$rules;

    my $module = ucfirst(lc $1);
    my $file = "lib/Dataninja/Bot/Command/$module.pm";

    return 'could not find command module'
        unless -f $file;
    
    # construct the commands here
    my $base    = 'lib/Dataninja/Bot/Command/';

    my $subclass = "Dataninja::Bot::Command::$module";
    warn $_;

    {
        my $dispatch;
        my $code = << "CODE";
            require $subclass;

            \$dispatch->{'name'}     = lc '\$module';
            \$dispatch->{'code'}     = ${subclass}->can('run');
            \$dispatch->{'usage'}    = ${subclass}->can('usage');
            \$dispatch->{'help'}     = ${subclass}->can('help');
            \$dispatch->{'pattern'}  = ${subclass}->can('pattern');

            push \@\$rules, \$dispatch;
CODE
    
        eval $code;
        die $@ if $@;
    }

    return "command $module added";
}

1;
