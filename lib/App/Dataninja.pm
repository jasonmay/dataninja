package App::Dataninja;
use Moose;
use Bread::Board::Declare;

has model => (
    is  => 'ro',
    isa => 'App::Dataninja::Model',
);

has hook_manager => (
    is  => 'ro',
    isa => 'App::Dataninja::HookManager',
);

has client => (
    is  => 'ro',
    isa => 'App::Dataninja::Client',
    dependencies => ['model', 'hook_manager'],
);

sub run {
    my $self = shift;
    $self->client->run_all;
}

no Moose;

1;
