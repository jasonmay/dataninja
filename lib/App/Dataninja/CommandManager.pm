package App::Dataninja::CommandManager;
use Moose;

has _commands => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

sub add_command {
    my $self = shift;
    my ($name, $body) = @_;
    $name = lc $name;

    $self->_commands->{$name}->{body} = $body;
}

sub commands {
    return keys( %{shift->_commands || {}} );
}

sub invoke {
    my $self = shift;
    my ($name, @args) = @_;

    $self->_commands->{$name}->{body}->(@args);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
