use strict;
use warnings;

package Dataninja::Model::Person;
use Jifty::DBI::Schema;

use Dataninja::Record schema {
};

# Your model-specific methods go here.
sub current_user_can { 1 }

1;

