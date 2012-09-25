package App::Presto::WithPrettyPrinter;
BEGIN {
  $App::Presto::WithPrettyPrinter::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::WithPrettyPrinter::VERSION = '0.006';
}

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

__END__
=pod

=head1 NAME

App::Presto::WithPrettyPrinter - Role that provides a pretty-printer

=head1 VERSION

version 0.006

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

