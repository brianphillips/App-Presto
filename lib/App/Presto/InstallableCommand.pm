package App::Presto::InstallableCommand;

# ABSTRACT: Role for command modules that can be installed

use Moo::Role;

has context => (
    is => 'ro',
    isa => sub { die "not an App::Presto" unless ref $_[0] eq 'App::Presto' },
    weak_ref => 1,
    handles => ['term','config', 'client','stash'],
);

requires 'install';

1;
