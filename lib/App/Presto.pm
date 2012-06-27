package App::Presto;

# ABSTRACT: provides CLI for performing REST operations

use Moo;
use App::Presto::CommandFactory;
use App::Presto::Config;
use App::Presto::Client;
use App::Presto::ShellUI;

has client => (
	is       => 'lazy',
);

sub _build_client {
	my $self = shift;
	return App::Presto::Client->new;
}

has config => (
	is       => 'rw',
	handles  => ['endpoint'],
);

sub _build_config {
	my $self = shift;
	return App::Presto::Config->new;
}

has term => (
	is => 'lazy',
);
sub _build_term {
	my $self = shift;
		my $help_categories = $self->command_factory->help_categories;
    return App::Presto::ShellUI->new(
        commands => {
            "help" => {
                exclude_from_completion => 1,
                exclude_from_history    => 1,
                desc                    => "Print helpful information",
                args => sub { shift->help_args( $help_categories, @_ ); },
                method => sub { shift->help_call( $help_categories, @_ ); }
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
        prompt       => sprintf( '%s> ', $self->endpoint ),
        history_file => $self->config->file('history'),
    );
}

has command_factory => (
	is => 'lazy',
);
sub _build_command_factory { return App::Presto::CommandFactory->new }

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
		$self->config( App::Presto::Config->new( endpoint => $endpoint ) );
	} else {
		die "Base endpoint (i.e. http://some-host.com) must be specified as command-line argument\n";
	}
	$self->command_factory->install_commands($self);

	return $self->term->run;
}

1;

