#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Dataninja::Bot;
use Dataninja::Config;
use Dataninja::Schema;
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
            print "Directory made.\n";

            DumpFile(
                "$dataninja_dir/config.yml",
                +{Main =>
                    {
                        database =>
                        {
                            name => 'dataninja',
                            host => 'localhost',
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
        }
    }
}

check_for_config;

my $config = Dataninja::Config->new;
my $database_config = $config->main->{database};

my $schema = Dataninja::Schema->connect(
    "dbi:Pg:dbname=$database_config->{name}",
    $database_config->{user},
    $database_config->{password}
);

my $bot = Dataninja::Bot->new($config, $network, $schema);
$bot->_plugin_app_ns(['Dataninja::Bot::Plugin']);
$bot->run;

__END__

=head1 BUTTS

=head2 FARTS

