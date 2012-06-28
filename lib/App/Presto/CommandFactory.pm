package App::Presto::CommandFactory;

# ABSTRACT: Responsible for installing all commands

use Moo;
use Module::Pluggable require => 1, sub_name => 'commands', search_path => ['App::Presto::Command'];

sub install_commands {
    my $self = shift;
    my $ctx = shift;
    foreach my $command_module($self->commands){
        my $command = $command_module->new( context => $ctx );
        $command->install;
    }
    return;
}

sub help_categories {
    my $self = shift;
    my %categories;
    foreach my $command_module($self->commands){
        if($command_module->does('App::Presto::CommandHasHelp') ){
            (my $short_module = $command_module) =~ s/^.*::Command:://;
            $short_module =~ s/::/-/g;
            $categories{$short_module} = $command_module->help_categories;
        }
    }
    return \%categories;
}

1;
