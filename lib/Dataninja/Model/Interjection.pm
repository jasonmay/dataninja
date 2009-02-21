use strict;
use warnings;

package Dataninja::Model::Interjection;
use Jifty::DBI::Schema;

use Dataninja::Record schema {
    column message =>
        type is 'text',
        is mandatory;

    column interjected =>
        is boolean;

    column network =>
        type is 'text',
        since '0.0.11';

    column channel =>
        type is 'text',
        since '0.0.11';
};

# Your model-specific methods go here.
sub since { '0.0.10' }
sub current_user_can { 1 }

1;

