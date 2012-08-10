package App::Presto::ShellUI;

# ABSTRACT: Term::ShellUI sub-class

use strict;
use warnings;
use Regexp::Common qw(balanced);
use Moo;
use App::Presto::ArgProcessor;
extends 'Term::ShellUI';

foreach my $m(qw(readline GetHistory)){
	no strict 'refs';
	*$m = sub { my $self = $_[0]; my $target = $self->{term}->can($m); $_[0] = $self->{term}; goto $target };
}

has arg_processor => (
	is       => 'lazy',
);

sub _build_arg_processor {
	my $self = shift;
	return App::Presto::ArgProcessor->new;
}

sub call_command {
	my $self = shift;
	my($cmd) = @_;
	my $args = $cmd->{args};
	eval {
		$self->arg_processor->process($args);
		1;
	} or do {
		warn "Error preparsing args @$args: $@";
	};
	return $self->SUPER::call_command(@_);
}

1;
