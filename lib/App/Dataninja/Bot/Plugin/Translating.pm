package App::Dataninja::Bot::Plugin::Translating;
use Moose;
use REST::Google::Translate;
extends 'App::Dataninja::Bot::Plugin';

REST::Google::Translate->http_referer('http://www.google.com');

=head1 NAME

App::Dataninja::Bot::Plugin::Translating - translation tools thanks to
L<REST::Google::Tranlsate>

=head1 COMMANDS

=over

=item * spanishify B<message>

The bot translates your message from English to Spanish.

=item * es B<message>

This is an alias for spanishify.

=item * englishify B<message>

The bot translates your message from Spanish to English.

=item * en B<message>

This is an alias for englishify.

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    my $create_translator = sub {
        my $langpair = shift;
        return sub {
            my $command_args = shift;
            my $result = REST::Google::Translate->new(
                q => $command_args,
                langpair => $langpair,
            );
            return $result->responseData->translatedText;
        };
    };

    $self->command(en => $create_translator->('es|en'));
    $self->command(es => $create_translator->('en|es'));

    $self->command(englishify => $create_translator->('es|en'));
    $self->command(spanishify => $create_translator->('en|es'));
};


__PACKAGE__->meta->make_immutable;
no Moose;

1;

