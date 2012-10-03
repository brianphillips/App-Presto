package App::Presto::InstallableCommand;
BEGIN {
  $App::Presto::InstallableCommand::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::InstallableCommand::VERSION = '0.007';
}

# ABSTRACT: Role for command modules that can be installed

use Moo::Role;
use Scalar::Util qw(blessed);

has context => (
    is => 'ro',
    isa => sub { die "not an App::Presto (it's a $_[0])" unless blessed $_[0] && $_[0]->isa('App::Presto') },
    weak_ref => 1,
    handles => ['term','config', 'client','stash'],
);

requires 'install';

1;

__END__
=pod

=head1 NAME

App::Presto::InstallableCommand - Role for command modules that can be installed

=head1 VERSION

version 0.007

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

