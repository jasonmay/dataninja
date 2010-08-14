#!/usr/bin/env perl
package App::Dataninja::Meta::Role::Command;
use Moose::Role;

has active => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1,
);

no Moose::Role;

1;
