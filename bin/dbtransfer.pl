#!/usr/bin/env perl
use strict;
use warnings;

use DBI;
use Jifty::Everything;
BEGIN { Jifty->new }

open DBPW, '/home/jasonmay/.dbpass';
my $dbpass = <DBPW>;
($dbpass) = $dbpass =~ /(.+)/;
close DBPW;

my $dbh;
$dbh = DBI->connect('dbi:Pg:dbname=jasonmay', 'jasonmay', $dbpass) 
	or die "DB connect problem.\n";

#my $msgs = Dataninja::Model:MessageCollection->new;
#$msgs->order_by(column => 'moment');
#$msgs->rows_per_page(1);
#my $msg = $msg->
#

my $moment;

($moment) = Jifty->handle->fetch_result("select max(moment) from messages");
my ($query, $sth);
if ($moment)
{
	$query = "select * from dataninja.message where moment > ? order by moment";
	$sth = $dbh->prepare($query);
	$sth->execute($moment);
}
else
{
	$query = "select * from dataninja.message order by moment";
	$sth = $dbh->prepare($query);
	$sth->execute;
}

my $n = 0; 
while (my $row = $sth->fetchrow_hashref)
{
	$row->{nick} = delete $row->{username};
	$row->{message} = delete $row->{msg};
	$row->{network} = 'efnet';
    next unless $row->{nick};
    next unless $row->{message};
#	use DDS; Dump $row;

	my $msg = Dataninja::Model::Message->new(current_user =>
			Dataninja::CurrentUser->superuser);

	my ($ok, $error) = $msg->create(%$row);
	$ok or die $error;
    warn $n if $n % 1000 == 0;
    ++$n;
}
