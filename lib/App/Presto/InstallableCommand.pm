package App::Presto::InstallableCommand;

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
