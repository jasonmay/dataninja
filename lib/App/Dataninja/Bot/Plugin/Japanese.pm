package App::Dataninja::Bot::Plugin::Japanese;
use Moose;
extends 'App::Dataninja::Bot::Plugin';
use Lingua::JA::Romanize::Japanese;

=head1 NAME

App::Dataninja::Bot::Plugin::Japanese - automatically transliterate Japanese into romaji

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->add_rule(
        Path::Dispatcher::Rule::Regex->new(
            regex => qr/\p{Hiragana}|\p{Katakana}|\p{Han}/,
            block => sub {
                return Lingua::JA::Romanize::Japanese->new->chars($_);
            },
        )
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

