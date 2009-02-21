#!/usr/bin/env perl
use strict;
use warnings;
package Dataninja::Bot::Command::Twentyfour;
use base 'Dataninja::Bot::Command';
use List::Permutor;
use List::Util qw/shuffle/;

sub pattern { qr|^#24\b$| }

sub do_op {
    my $op = shift;
    return sub { $_[0] + $_[1] } if $op eq '+';
    return sub { $_[0] - $_[1] } if $op eq '-';
    return sub { $_[0] * $_[1] } if $op eq '*';
    return sub { $_[0] / $_[1] } if $op eq '/';
}

sub twenty_four {
    die if @_ != 4;
    my @numbers = @_;
    my @operators = qw{+ - * /};
    my $number_perm = List::Permutor->new(@numbers);
    while (my @set = $number_perm->next) {
        foreach my $op1 (@operators) {
            foreach my $op2 (@operators) {
                foreach my $op3 (@operators) {
                    my $result = 0;
                    next if ($op1 eq '/' && $numbers[0] % $numbers[1] != 0);
                    next if ($op2 eq '/' && $numbers[1] % $numbers[2] != 0);
                    next if ($op3 eq '/' && $numbers[2] % $numbers[3] != 0);
                    next unless "$op1$op2$op3" =~ m{[*/]};

                    $result = do_op($op1)->($numbers[0], $numbers[1]);
                    $result = do_op($op2)->($result, $numbers[2]);
                    $result = do_op($op3)->($result, $numbers[3]);


                    if ($result == 24) {
# warn "$op1 $op2 $op3";
                        return 1; 
                    }
                }
            }
        }
    }
    
    0 # :(
}

sub run {
    my $n = 0; 
    my @nums;
    do {
        @nums = ();
        push @nums, int(rand 24)+1 for (1 .. 4);
        return "fail" if ++$n > 1000;
    } until (twenty_four @nums);
    return join(' ', shuffle @nums) . "\n";
}

1;