package Dataninja::Bot::Plugin::Translating;
use Moose;
use REST::Google::Translate;
extends 'Dataninja::Bot::Plugin::Base';

REST::Google::Translate->http_referer('http://www.google.com');

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    my $englishify = sub {
        my $command_args = shift;
        my $result = REST::Google::Translate->new(
            q => $command_args,
            langpair => 'es|en',
        );
        return $result->responseData->translatedText;
    };

    my $spanishify = sub {
        my $command_args = shift;
        my $result = REST::Google::Translate->new(
            q => $command_args,
            langpair => 'en|es',
        );
        return $result->responseData->translatedText;
    };

    $self->command(en => $englishify);
    $self->command(es => $spanishify);

    $self->command(englishify => $englishify);
    $self->command(spanishify => $spanishify);
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

