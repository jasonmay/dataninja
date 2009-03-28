package Dataninja::Bot::Plugin::Last;
use App::Nopaste 'nopaste';
use Moose;
extends 'Dataninja::Bot::Plugin::Base';

sub _line {
    my ($timestamp, $nick, $message) = @_;
    return sprintf("%s <%s> %s", $timestamp, $nick, $message);
}

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(
        last => sub {
            my $command_args = shift;
            my $messages = Dataninja::Model::MessageCollection->new;
            $messages->limit(column => 'network', value => $self->network);
            $messages->limit(column => 'channel', value => $self->channel);
            $messages->order_by(column => 'moment', order => 'desc');

            my $num = defined $1 ? $1 : 25;
            $num = 200 if $num > 200;
            $num = 10 if $num < 10;
            $messages->rows_per_page($num);

            return "Last $num lines: " . nopaste(
                join qq{\n} =>
                map {
                    _line($_->moment, $_->nick->name, $_->message)
                } reverse @$messages
            );
        });
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

