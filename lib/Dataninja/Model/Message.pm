use strict;
use warnings;

package Dataninja::Model::Message;
use Jifty::DBI::Schema;

use Dataninja::Record schema {
	column nick =>
		refers_to Dataninja::Model::Nick by 'name',
		type is 'text',
		is mandatory;

	column message =>
		type is 'text',
		is mandatory;

	column moment =>
		type is 'timestamptz',
		is mandatory;

	column channel =>
		type is 'text',
		is mandatory;

	column network =>
		type is 'text',
		is mandatory;

	column lines =>
		is virtual;

	column bytes =>
		is virtual;
};

# Your model-specific methods go here.
sub current_user_can { 1 }

sub before_create {
	my ($self, $args) = @_;
	my $nick = Dataninja::Model::Nick->new();
	$nick->load_or_create(
		name => $args->{'nick'},
		network => $args->{'network'}
	);
}

1;

