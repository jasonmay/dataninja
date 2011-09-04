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

has model => (
    is       => 'ro',
    isa      => 'App::Dataninja::Model',
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

has component => (is  => 'rw');

sub setup {
    my $self = shift;
    my ($component) = @_;
    $self->component($component);

    # read the plugins from the config and set them up
    foreach my $plugin (keys %{$self->config->{Plugins} || {}}) {
        my $value = $self->config->{Plugins}->{$plugin};
        next unless $value;
        next if lc($value) eq 'no';

        my $plugin_class = "App::Dataninja::Plugin::$plugin";
        Class::MOP::load_class($plugin_class);

        local $App::Dataninja::Plugin::PLUGINSUB{command} = sub {
            $self->add_command(@_);
        };
        local $App::Dataninja::Plugin::PLUGINSUB{add_hook} = sub {
            $self->hook_manager->add_hook(@_);
        };

        $plugin_class->setup($self);
    }
}

sub send_message { shift->component->yield('privmsg', @_) }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
