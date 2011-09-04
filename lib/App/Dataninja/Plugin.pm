package App::Dataninja::Plugin;
use strict;
use warnings;

use Exporter;
BEGIN {
    our @ISA = qw(Exporter);
    our %PLUGINSUB;
    my @subs = qw(
        command
        send_message
        add_hook
    );
    our @EXPORT = @subs;
    my $override_this_sub = sub {
        die "Must be used in a plugin's setup() method";
    };

    for my $sub (@subs) {
        no strict 'refs';
        $PLUGINSUB{$sub} = $override_this_sub;
        *$sub = sub { $PLUGINSUB{$sub}->(@_) };
    }
}


1;
