package Dataninja::Config;
use Moose;
use YAML 'LoadFile';
use Hash::Merge qw/merge/;
use DDS;

has default_config => (
    is  => 'rw',
    isa => 'Str',
    default => 'etc/config.yml',
);

has site_config => (
    is  => 'rw',
    isa => 'Str',
    default => 'etc/site_config.yml',
);

has secret_config => (
    is  => 'rw',
    isa => 'Str',
    default => 'etc/secret_config.yml',
);

has main => (
    is  => 'rw',
    isa => 'Any',
    default => sub { +{} },
);

has site => (
    is  => 'rw',
    isa => 'Any',
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
