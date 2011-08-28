package App::Dataninja::HookManager;
use Moose;

has _hook_lookup => (
    is      => 'ro',
    isa     => 'HashRef[HashRef[CodeRef]]',
    default => sub { {} },
);

sub get_hooks_for {
    my $self = shift;
    my ($register, $name) = @_;

    return values(%{ $self->_hook_lookup->{$register} || {} });
}

sub add_hook {
    my $self = shift;
    my ($register, $name, $callback) = @_;

    $self->_hook_lookup->{$register}->{$name} = $callback;
}

sub remove_hook {
    my $self = shift;
    my ($register, $name) = @_;

    delete $self->_hook_lookup->{$register}->{$name};
}

no Moose;

1;
