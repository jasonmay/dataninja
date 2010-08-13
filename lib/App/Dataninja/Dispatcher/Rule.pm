#!/usr/bin/env perl
package App::Dataninja::Dispatcher::Rule;
use Moose;
use namespace::autoclean;

extends 'Path::Dispatcher::Rule';

has config => (
    is       => 'ro',
    isa      => 'App::Dataninja::Config',
    required => 1,
);

=head1 NAME

=head1 SYNOPSIS


=head1 DESCRIPTION


=cut



__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 METHODS


=head1 AUTHOR

Jason May C<< <jason.a.may@gmail.com> >>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

