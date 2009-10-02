package App::Dataninja::Bot::Plugin::Japanese;
use Moose;
extends 'App::Dataninja::Bot::Plugin';
use Lingua::JA::Romanize::Japanese;
use Encode;

=head1 NAME

App::Dataninja::Bot::Plugin::Japanese - automatically transliterate Japanese into romaji

=cut

sub extra_primary_dispatcher_rules {
     Path::Dispatcher::Rule::CodeRef->new(
         matcher => sub {
             my $decoded = Encode::decode_utf8($_);
             $decoded =~ /\p{Hiragana}|\p{Katakana}|\p{Han}/;
         },
         block => sub {
             my $decoded = Encode::decode_utf8($_);
             return Lingua::JA::Romanize::Japanese->new->chars($decoded);
         },
     )
}


#around 'command_setup' => sub {
#    my $orig = shift;
#    my $self = shift;
#
#    $self->add_rule(
#        Path::Dispatcher::Rule::CodeRef->new(
#            matcher => sub {
#                my $decoded = Encode::decode_utf8($_);
#                $decoded =~ /\p{Hiragana}|\p{Katakana}|\p{Han}/;
#            },
#            block => sub {
#                return Lingua::JA::Romanize::Japanese->new->chars($_);
#            },
#        )
#    );
#};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

