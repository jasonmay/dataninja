package App::Dataninja::Engine;
use Moose;
use IM::Engine;
use Encode;
use List::Util qw(first);

has im_engine => (
    is => 'ro',
    isa => 'IM::Engine',
    lazy => 1,
    builder => '_build_im_engine',
    handles => ['run', 'send_message'],
);

has config => (
    is => 'rw',
    isa => 'App::Dataninja::Config',
    required => 1,
);

has dispatcher => (
    is => 'rw',
    isa => 'Path::Dispatcher',
    required => 1,
);

has storage => (
    is => 'rw',
    isa => 'App::Dataninja::Storage',
    required => 1,
);

has profile => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

# builders

sub _build_im_engine { IM::Engine->new(shift->_make_im_engine_args) }

sub _make_im_engine_args {
    my $self = shift;
    my $profile = $self->_get_profile_data;

    return (
        interface => {
            protocol => 'IRC',
            credentials => {
                server   => $profile->{server},
                port     => 6667,
                channels => [map { $_->{name} } @{$profile->{channels}}],
                nick     => $self->config->site->{nick},
            },
            incoming_callback => sub { $self->_handle_incoming(@_) },
        }
    )
}

sub _handle_incoming {
    my $self     = shift;
    my $incoming = shift;

    if ($incoming->isa('IM::Engine::Incoming::IRC::Privmsg')) {
        return $incoming->reply('PMing me! getting frisky are we?');
    }

    my $message = $incoming->plaintext;

    my $profile = $self->_get_profile_data;

    $self->storage->add_message(
        channel => $incoming->channel,
        nick    => $incoming->sender->name,
        message => $incoming->plaintext,
    );

    my ($prefix, $channel_data);
    if ($incoming->isa('IM::Engine::Incoming::IRC::Channel')) {
        $channel_data = first {
            lc($_->{name}) eq lc($incoming->channel)
        } @{ $profile->{channels} };

        $prefix = $profile->{prefix}
        || $channel_data->{prefix};
    }

    my $request = $incoming->plaintext;
    my $response = undef;
    if ($prefix) {
        my $plen = length($prefix);
        if (substr($request, 0, $plen) eq $prefix) {
            $request = substr($request, $plen) or return undef;

            my ($command, $args) = split ' ', $request, 2;
            my $dispatch = $self->dispatcher->dispatch($command);

            return undef unless $dispatch->has_matches;

            $response = $dispatch->run(
                $args,
                $incoming,
                $self->profile,
                $self->storage,
            );

            substr($response, 512) = q{}
                if $response && length($response) > 512;

            $self->storage->log_response(
                channel  => $incoming->channel,
                response => $response,
            );
        }
        else {
            return undef;
        }
    }

    $response = Encode::encode("iso-8859-1", Encode::decode_utf8($response));

    return $incoming->reply($response);
}

sub _get_profile_data {
    my $self = shift;

    return $self->config->site->{networks}{$self->profile};
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
