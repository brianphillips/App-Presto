package App::REST::CLI;

# ABSTRACT: provides CLI for performing REST operations

use Moo;
use App::REST::CLI::CommandFactory;
use App::REST::CLI::Config;

has config => (
	is       => 'lazy',
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
	return Term::ShellUI->new( commands => {});
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
		$self->config->set( endpoint => $endpoint );
	}
	my $command_factory = App::REST::CLI::CommandFactory->new;
	$command_factory->install_commands($self);
	return $self->term->run;
}

1;
