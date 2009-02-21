use strict;
use warnings;

package Dataninja::Model::Nick;
use Jifty::DBI::Schema;

use Dataninja::Record schema {
	column name =>
		type is 'text',
		is mandatory;

	column network =>
		type is 'text',
		is mandatory;
};

# Your model-specific methods go here.
sub current_user_can { 1 }

1;

