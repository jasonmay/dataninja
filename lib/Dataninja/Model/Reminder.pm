use strict;
use warnings;

package Dataninja::Model::Reminder;
use Jifty::DBI::Schema;

use Dataninja::Record schema {
    column moment =>
        type is 'timestamp',
        is mandatory;

    column description => type is 'text';
    column remindee    => type is 'text';
    column maker       => type is 'text', since '0.0.13';
    column channel     => type is 'text';
    column network     => type is 'text';

    column reminded    =>
        is boolean,
        since '0.0.8';
    column canceled    =>
        is boolean,
        since '0.0.12';
};

# Your model-specific methods go here.
sub since { '0.0.3' }
sub current_user_can { 1 }

1;

