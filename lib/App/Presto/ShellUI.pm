package App::Presto::ShellUI;
BEGIN {
  $App::Presto::ShellUI::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::ShellUI::VERSION = '0.005';
}

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

sub ornaments {
	shift->{term}->ornaments(@_);
}

1;

__END__
=pod

=head1 NAME

App::Presto::ShellUI - Term::ShellUI sub-class

=head1 VERSION

version 0.005

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

