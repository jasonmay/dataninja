package App::Dataninja::Model;
use Moose;
extends 'KiokuX::Model';

sub lookup_network {
    my $self = shift;
    my $name = shift;

    return $self->lookup("dn:network:$name");
}

sub lookup_nick {
    my $self    = shift;
    my $network = shift;
    my $name    = shift;

    return $self->lookup("dn:nick:$network:$name");
}

sub lookup_channel {
    my $self    = shift;
    my $network = shift;
    my $channel = shift;

    return $self->lookup("dn:channel:$network:$channel");
}

no Moose;

require App::Dataninja::Schema::Channel;
require App::Dataninja::Schema::Interjection;
require App::Dataninja::Schema::Message;
require App::Dataninja::Schema::Network;
require App::Dataninja::Schema::Nick;
require App::Dataninja::Schema::Reminder;

1;

