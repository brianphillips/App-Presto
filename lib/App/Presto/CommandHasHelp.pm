package App::Presto::CommandHasHelp;

# ABSTRACT: Role for command modules that have help defined

use Moo::Role;

requires 'help_categories';

1;
