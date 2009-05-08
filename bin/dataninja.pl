#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use App::Dataninja::Bot;
use App::Dataninja::Config;
use App::Dataninja::Schema;
use DBICx::Deploy;
use YAML::XS 'DumpFile';

my $network = shift;

sub check_for_config {
    my $dataninja_dir = "$ENV{HOME}/.dataninja";
    if (!-e "$dataninja_dir/config.yml") {
        print "Could not access the ~/.dataninja directory. "
            . "Would you like me to set up a default configuration for you? "
            . "[y]es to proceed: ";
        chomp(my $input = <>);
        if (length $input == 0 or lc $input =~ /y(es)?/) {
            mkdir $dataninja_dir unless -d $dataninja_dir;

            print "I will now build a default configuration for you. "
                . "Please edit the database password in your "
                . "secret.yml if necessary.\n";

#            print "A schema.psql file will be supplied to you in ~/.dataninja "
#                . "as well.\nPlease load the schema into your PostgreSQL "
#                . "database.\n";
#
#            print "You may do all of the following now and then press enter "
#                . "when you are finished.";

            DumpFile(
                "$dataninja_dir/config.yml",
                +{Main =>
                    {
                        database =>
                        {
                            name   => "$dataninja_dir/dataninja.sqlite",
                            host   => 'localhost',
                            driver => 'SQLite',
                        }
                    }
                }
            );

            DumpFile(
                "$dataninja_dir/site_config.yml",
                +{
                    Site => {
                        nick     => 'dataninja',
                        networks => {
                            dev => {
                                server => 'localhost',
                                channels => [
                                    {name => '#dataninja'},
                                    {
                                        name   => '#otherchan',
                                        prefix => '@',
                                    }
                                ],
                                prefix   => '!',
                            },
                        },
                    }
                }
            );

            DumpFile(
                "$dataninja_dir/secret_config.yml",
                +{
                    Main => {
                        database => {
                            pasword => 'XXXXXXXX',
                            user    => 'please_edit_your_config'
                        }
                    }
                }
            );

            DBICx::Deploy->deploy('App::Dataninja::Schema'
                => "DBI:SQLite:$dataninja_dir/dataninja.sqlite");
        }
    }
}

check_for_config;

my $config = App::Dataninja::Config->new;
my $database_config = $config->main->{database};

my $schema = App::Dataninja::Schema->connect(
    "dbi:$database_config->{driver}:dbname=$database_config->{name}",
    $database_config->{user},
    $database_config->{password}
);

$network ||= 'dev';

my $bot = App::Dataninja::Bot->new(
    config           => $config,
    assigned_network => $network,
    schema           => $schema
);
$bot->run;

__END__

=head1 NAME

dataninja.pl - run the App::Dataninja bot

=head1 SYNOPSIS

    dataninja.pl [network]

This command runs the bot. The network is optional, and defaults to 'dev'.  The
network information is supplied in your config. This is in C<~/.dataninja/>.
Dataninja supplies these configurations for you when you run C<dataninja.pl>
for the first time.

=head1 AUTHOR

Jason May C<< <jason.a.may@gmail.com> >>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
