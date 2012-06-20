package App::REST::CLI;

# ABSTRACT: provides CLI for performing REST operations

use Moo;
use App::REST::CLI::CommandFactory;
use App::REST::CLI::Config;
use App::REST::CLI::Client;
use App::REST::CLI::ShellUI;

has client => (
	is       => 'lazy',
);

sub _build_client {
	my $self = shift;
	return App::REST::CLI::Client->new;
}

has config => (
	is       => 'rw',
	handles  => ['endpoint'],
);

sub _build_config {
	my $self = shift;
	return App::REST::CLI::Config->new;
}

has term => (
	is => 'lazy',
);
sub _build_term {
	my $self = shift;
    return App::REST::CLI::ShellUI->new(
        commands => {
            "help" => {
                exclude_from_completion => 1,
                exclude_from_history    => 1,
                desc                    => "Print helpful information",
                args => sub { shift->help_args( undef, @_ ); },
                method => sub { shift->help_call( undef, @_ ); }
            },
            "h" => {
                alias                   => "help",
                exclude_from_completion => 1,
                exclude_from_history    => 1,
            },
            quit => {
                desc                    => "Exits the REST shell",
                maxargs                 => 0,
                exclude_from_completion => 1,
                exclude_from_history    => 1,
                method                  => sub { shift->exit_requested(1) },
            },
            "history" => {
                exclude_from_completion => 1,
                exclude_from_history    => 1,
                desc                    => "Prints the command history",
                args                    => "[-c] [-d] [number]",
                method                  => sub { shift->history_call(@_) },
                doc => "Specify a number to list the last N lines of history Pass -c to clear the command history, -d NUM to delete a single item\n",
            },
        },
        prompt       => sprintf( '%s >', $self->endpoint ),
        history_file => $self->config->file('history'),
    );
}

my $SINGLETON;
sub instance {
	my $class = shift;
	return $SINGLETON ||= $class->new(@_);
}
sub run {
	my $class = shift;
	my $self = $class->instance;
	my @args  = shift;
	if(my $endpoint = shift(@args)){
		$self->config( App::REST::CLI::Config->new( endpoint => $endpoint ) );
	} else {
		die "Endpoint must be specified as command-line argument\n";
	}
	my $command_factory = App::REST::CLI::CommandFactory->new;
	$command_factory->install_commands($self);

	return $self->term->run;
}

1;
