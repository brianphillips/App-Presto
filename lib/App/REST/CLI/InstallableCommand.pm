package App::REST::CLI::InstallableCommand;

use Moo::Role;

has context => (
    is => 'ro',
    isa => sub { die "not an App::REST::CLI" unless ref $_[0] eq 'App::REST::CLI' },
    weak_ref => 1,
    handles => ['term','config', 'client'],
);

requires 'install';

1;
