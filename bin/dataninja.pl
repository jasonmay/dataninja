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

            print "I will now build a default configuration for you. "
                . "Please edit the database password in your "
                . "secret.yml.\n";

            print "A schema.psql file will be supplied to you in ~/.dataninja "
                . "as well.\nPlease load the schema into your PostgreSQL "
                . "database.\n";

            print "You may do all of the following now and then press enter "
                . "when you are finished.";

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

            # heredocs were spazzing out!
            open my $fh, '>', "$dataninja_dir/schema.psql";
            print $fh join("\n" =>
                "CREATE TABLE areas (",
                "    id serial NOT NULL,",
                "    location text,",
                "    nick text,",
                "    network text",
                ");",
                "",
                "CREATE TABLE messages (",
                "    id serial NOT NULL,",
                "    nick text NOT NULL,",
                "    message text NOT NULL,",
                "    moment timestamp with time zone NOT NULL,",
                "    channel text NOT NULL,",
                "    network text NOT NULL",
                ");",
                "",
                "CREATE TABLE interjections (",
                "    id serial NOT NULL,",
                "    message text NOT NULL,",
                "    interjected boolean DEFAULT false,",
                "    channel text,",
                "    network text",
                ");",
                "",
                "CREATE TABLE nicks (",
                "    id serial NOT NULL,",
                "    name text NOT NULL,",
                "    network text NOT NULL",
                ");",
                "",
                "CREATE TABLE reminders (",
                "    id serial NOT NULL,",
                "    moment timestamp with time zone NOT NULL,",
                "    description text,",
                "    remindee text,",
                "    channel text,",
                "    network text,",
                "    reminded boolean DEFAULT false,",
                "    canceled boolean DEFAULT false,",
                "    maker text",
                ");",
            );
            close $fh;

            <>; # let the user press enter
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
$bot->run;

__END__

=head1 NAME

dataninja.pl - run the Dataninja bot

=head1 SYNOPSIS

To run the bot (the network is optional, and results to 'dev'):

    dataninja.pl [network]

The network information is supplied in your config. This is in ~/.dataninja/
(which dataninja supplies for you when you run C<dataninja.pl> for the first
time.).

=head1 AUTHOR

Jason May C<< <jason.a.may@gmail.com> >>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
