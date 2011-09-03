package App::Dataninja;
use Moose;
use Bread::Board::Declare;

use Config::INI::Reader;

has model => (
    is        => 'ro',
    isa       => 'App::Dataninja::Model',
    lifecycle => 'Singleton',
);

has hook_manager => (
    is        => 'ro',
    isa       => 'App::Dataninja::HookManager',
    lifecycle => 'Singleton',
);

has network => (
    is        => 'ro',
    isa       => 'Str',
    required  => 1,
    lifecycle => 'Singleton',
);

has command_manager => (
    is        => 'ro',
    isa       => 'App::Dataninja::CommandManager',
    lifecycle => 'Singleton',
);

has plugin_manager => (
    is           => 'ro',
    isa          => 'App::Dataninja::PluginManager',
    dependencies => ['hook_manager', 'command_manager', 'config', 'network'],
    lifecycle    => 'Singleton',
);

has client => (
    is           => 'ro',
    isa          => 'App::Dataninja::Client',
    dependencies => ['model', 'hook_manager', 'network', 'config', 'plugin_manager', 'command_manager'],
    lifecycle    => 'Singleton',
);

has config => (
    is        => 'ro',
    block     => sub { Config::INI::Reader->read_file('config.ini') },
    lifecycle => 'Singleton',
);

sub BUILD {
    my $self = shift;
    $self->plugin_manager->setup();
}

sub run {
    my $self = shift;
    $self->client->run_all;
}

no Moose;

1;
