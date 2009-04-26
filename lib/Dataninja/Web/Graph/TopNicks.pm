package Dataninja::Web::Graph::TopNicks;
use Moose;
extends 'Chart::Clicker';
use Dataninja::Schema;
use Chart::Clicker::Renderer::Bar;

has nick_keys => (
    is        => 'rw',
    isa       => 'ArrayRef[Str]',
);

has nick_values => (
    is        => 'rw',
    isa       => 'ArrayRef[Int]',
);

has bars => (
    is       => 'rw',
    isa      => 'Int',
    default  => 10,
);

sub BUILD {
    my $self = shift;

    my @nick_values = @{$self->nick_values};
    @nick_values = splice @nick_values, 0 => $self->bars;
    warn "@nick_values";
    my $keycount = scalar @{$self->nick_keys};

    my $color = Graphics::Color::RGB->new(
        red   => 0.644,
        green => 0.681,
        blue  => 0.709,
        alpha => 1,
    );

    $self->legend->visible(0);
    $self->plot->grid->visible(0);

    my $white = Graphics::Color::RGB->new({red => 1, green => 1, blue => 1});
    $self->color_allocator->colors([$color]);

    my $series = Chart::Clicker::Data::Series->new(
        keys   => [1 .. (($keycount > $self->bars ? $self->bars : $keycount))],
        values => [@nick_values],
    );

    $self->width($self->bars * 50 + 100);

    my $context = $self->get_context('default');
    $context->renderer(Chart::Clicker::Renderer::Bar->new);
    $context->renderer->brush->color(
        Graphics::Color::RGB->new(
            red   => 0,
            green => 0,
            blue  => 1,
            alpha => 1,
        )
    );
    $context->renderer->brush->width(2);
    $context->domain_axis->ticks($self->bars);
    $context->range_axis->baseline(0);
    $context->domain_axis->staggered(1);
    $context->domain_axis->fudge_amount(1/$self->bars);
    $self->add_to_datasets(
        Chart::Clicker::Data::DataSet->new(series => [$series])
    );
}

before 'draw' => sub {
    my $self = shift;
    my $domain = $self->get_context('default')->domain_axis;
    $domain->tick_labels($self->nick_keys);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

