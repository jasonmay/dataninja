package App::Dataninja::Commands::Japanese;
use App::Dataninja::Commands::OO;
use Lingua::JA::Romanize::Japanese;
use Encode;

=head1 NAME

App::Dataninja::Commands::Japanese - automatically transliterate Japanese into romaji

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

__PACKAGE__->meta->make_immutable;
no Moose;

1;

