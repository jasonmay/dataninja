package App::Dataninja::PluginManager;
use Moose;
use Class::MOP ();

use lib glob('plugin/*/lib');

has hook_manager => (
    is       => 'ro',
    isa      => 'App::Dataninja::HookManager',
    required => 1,
);

has command_manager => (
    is       => 'ro',
    isa      => 'App::Dataninja::CommandManager',
    handles  => ['add_command'],
    required => 1,
);

has config => (
    is       => 'ro',
    required => 1,
);

has network => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub setup {
    my $self = shift;

    # read the plugins from the config and set them up
    foreach my $plugin (keys %{$self->config->{Plugins} || {}}) {
        my $value = $self->config->{Plugins}->{$plugin};
        next unless $value;
        next if lc($value) eq 'no';

        my $plugin_class = "App::Dataninja::Plugin::$plugin";
        Class::MOP::load_class($plugin_class);
        $plugin_class->setup($self);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
