package App::Presto::InstallableCommand;
BEGIN {
  $App::Presto::InstallableCommand::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::InstallableCommand::VERSION = '0.001';
}

# ABSTRACT: Role for command modules that can be installed

use Moo::Role;

has context => (
    is => 'ro',
    isa => sub { die "not an App::Presto" unless ref $_[0] eq 'App::Presto' },
    weak_ref => 1,
    handles => ['term','config', 'client'],
);

requires 'install';

1;

__END__
=pod

=head1 NAME

App::Presto::InstallableCommand - Role for command modules that can be installed

=head1 VERSION

version 0.001

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

