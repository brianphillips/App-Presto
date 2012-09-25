package App::Presto::CommandHasHelp;
BEGIN {
  $App::Presto::CommandHasHelp::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::CommandHasHelp::VERSION = '0.006';
}

# ABSTRACT: Role for command modules that have help defined

use Moo::Role;

requires 'help_categories';

1;

__END__
=pod

=head1 NAME

App::Presto::CommandHasHelp - Role for command modules that have help defined

=head1 VERSION

version 0.006

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

