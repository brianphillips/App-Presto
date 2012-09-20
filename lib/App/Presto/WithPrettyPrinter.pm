package App::Presto::WithPrettyPrinter;

# ABSTRACT: Role that provides a pretty-printer

use strict;
use warnings;
use Moo::Role;
use App::Presto::PrettyPrinter;

requires 'config';

has pretty_printer => (
    is => 'lazy',
    handles => ['pretty_print'],
);

sub _build_pretty_printer {
    return App::Presto::PrettyPrinter->new( config => shift->config );
}

1;
