package App::Dataninja::Config;
use Moose;
use YAML::XS 'LoadFile';
use Hash::Merge qw/merge/;

=head1 NAME

App::Dataninja::Config - L<App::Dataninja> configuration through YAML files

=head1 DESCRIPTION

This is the class you use to grab information from config files, such as
the channels that the bot connects to, his nick, database
information, that list goes on.

There are three attributes: there are three configurations:  B<default>,
B<site>, and B<secret>. In the end, the configurations are merged (secret
having the most precedence, and default having the least).

=head1 ATTRIBUTES

=head2 default_config

(C<Str>) File for the default configuration for App::Dataninja (for things such
as database name and host). If no file is specified, it defaults
to C<~/.dataninja/config.yml>.

=head2 site_config

(C<Str>) File for site-specific information. This includes things like IRC
networks, channels, command prefixes, and any  custom data you like.
The file defaults to C<~/.dataninja/site_config.yml>. See
C<~/.dataninja/example_site_config.yml>
for details.

=head2 secret_config

(C<Str>) File for storing secret information such as passwords. This file
defaults to C<~/.dataninja/secret_config>.

=head2 main

(C<HashRef>) The object that has all the configuation information for the main 
configuration, such as database information.

=head2 site

(C<HashRef>) The object that has all the site-specific configuation information,
such as external applicaiton credentials, channels, the nick of the bot, etc.

=cut

has default_config => (
    is  => 'rw',
    isa => 'Str',
    default => "$ENV{HOME}/.dataninja/config.yml",
);

has site_config => (
    is  => 'rw',
    isa => 'Str',
    default =>  "$ENV{HOME}/.dataninja/site_config.yml",
);

has secret_config => (
    is  => 'rw',
    isa => 'Str',
    default => "$ENV{HOME}/.dataninja/secret_config.yml",
);

has main => (
    is  => 'rw',
    isa => 'HashRef',
    default => sub { +{} },
);

has site => (
    is  => 'rw',
    isa => 'HashRef',
    default => sub { +{} },
);

sub BUILD {
    my $self = shift;
    my $default_config = LoadFile($self->default_config);
    my $site_config    = LoadFile($self->site_config);
    my $secret_config  = LoadFile($self->secret_config);

    Hash::Merge::set_behavior('RIGHT_PRECEDENT');

    my $result = merge($default_config, $site_config);
    $result    = merge($result        , $secret_config);

    $self->main($result->{Main});
    $self->site($result->{Site});
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
