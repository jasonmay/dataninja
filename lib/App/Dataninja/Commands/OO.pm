#!/usr/bin/env perl
package App::Dataninja::Commands::OO;

use Moose ();
use Moose::Exporter;

use Scalar::Util;

Moose::Exporter->setup_import_methods(with_caller => ['command']);

# TODO provide base class?
sub init_meta { shift; Moose->init_meta(@_); }

sub command {
    my $caller = shift;
    my ($names, $code) = @_;

    my @names =
        (ref $names and Scalar::Util::reftype($names) eq 'ARRAY') ?  @$names : ($names);

    my $method_metaclass = $caller->meta->method_metaclass;

    for (@names) {

        my $method_meta = Moose::Meta::Class->create_anon_class(
            superclasses => [$method_metaclass],
            roles        => ['App::Dataninja::Meta::Role::Command'],
        );

        my $method = $method_meta->name->wrap(
            $code,
            name         => $_,
            package_name => $caller,
        );

        $caller->meta->add_method(
            "__DATANINJA__$_" => $method,
        );

    }
}

1;

