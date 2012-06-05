package App::REST::CLI::CommandFactory;

use Moo;
use Module::Pluggable require => 1, sub_name => 'commands', search_path => ['App::REST::CLI::Command'];

sub install_commands {
    my $self = shift;
    my $ctx = shift;
    foreach my $command_module($self->commands){
        next if $command_module =~ /shell/;
        my $command = $command_module->new( context => $ctx );
        $command->install;
    }
    return;
}

1;
