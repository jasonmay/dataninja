use strict;
use warnings;

package Dataninja::Model::Area;
use Jifty::DBI::Schema;

use Dataninja::Record schema {
    column 'location' =>
        type is 'text';

    column 'nick' =>
        type is 'text';

    column 'network' =>
        type is 'text';
};

# Your model-specific methods go here.
sub since { '0.0.14' }
sub current_user_can { 1 }

sub update_or_create {
    my $self = shift;
    my ($network, $nick, $location) = @_;

    return "@_";
}

1;

