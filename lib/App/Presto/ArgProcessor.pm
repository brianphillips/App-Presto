package App::Presto::ArgProcessor;
BEGIN {
  $App::Presto::ArgProcessor::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::ArgProcessor::VERSION = '0.004';
}

# ABSTRACT: Term::ShellUI sub-class

use strict;
use warnings;
use Regexp::Common qw(balanced);
use Moo;

has _stash => (
	is      => 'lazy',
	handles => ['stash'],
);
sub _build__stash {
	return App::Presto->instance->_stash;
}

has client => (
	is       => 'lazy',
);

sub _build_client {
	return App::Presto->instance->client;
}

has term => (
	is       => 'lazy',
);

sub _build_term {
	return App::Presto->instance->term;
}

sub process {
    my $self = shift;
    my $args  = shift;
		foreach my $i ( 0 .. $#{$args} ) {
			my $arg = $args->[$i];
			if ( $arg =~ m{^#} ) {    # comments
				splice( @$args, $i );    # everything else is a comment
				last;
			} elsif ( $arg =~ m[^(\$$RE{balanced}{-keep})$] ) {                            # full substitutions
				$args->[$i] = $self->_expand_param( substr( $2, 1, -1 ), $1 );
			} else {                     # this one gets interpolated
				$args->[$i] =~ s[(\$$RE{balanced}{-keep})][my $result = $self->_expand_param(substr($2,1,-1),$1); ref($result) eq 'ARRAY' ? join(',', @$result) : $result]eg;
			}
		}
		return $args;
}

sub _expand_param {
	my $self = shift;
	my $param = shift;
	my $orig  = shift;
	my $replacement = '';
	if($param =~ m/^(BODY|HEADER)\b(.*)/){
		$replacement = $self->_expand_response_param($1,$2);
	} elsif($param =~ m/^STASH($RE{balanced}{-parens => '[]'})(\/.*)?/){
		my ($key, $dpath) = ($1, $2);
		$replacement = $self->stash(substr($key,1,-1));
		if($dpath){
			$replacement = _apply_dpath($replacement, $dpath)
		}
	} elsif($param =~ m/^PROMPT($RE{balanced}{-parens => '[]'})($RE{balanced}{-parens => '[]'})?/){
		my($prompt,$default) = ($1, $2);
		$replacement = $self->term->readline( substr( $prompt, 1, -1 ) . ' ', ($default ? substr( $default, 1, -1 ) : () ) );
	}
	return defined $replacement ? $replacement : $orig;
}

sub _expand_response_param {
	my $self = shift;
	my $section = shift;
	my $sub_section = shift;
	my $client = $self->client;
	if($section eq 'HEADER' && $sub_section =~ m/($RE{balanced}{-parens => '[]'})/){
		return $client->response->header(substr($1,1,-1));
	} elsif($section eq 'BODY'){
		if(!$sub_section){
			return $client->response_data;
		} elsif( $sub_section =~ m{^/} ){
			return _apply_dpath($client->response_data, $sub_section);
		}
	} 
	return undef;
}

sub _apply_dpath {
	my $data = shift;
	my $path = shift;
	require Data::DPath;
	my $dpath = Data::DPath::Path->new(path => $path);
	my @matches = $dpath->match($data);
	return @matches > 1 ? \@matches : $matches[0];
}

1;

__END__
=pod

=head1 NAME

App::Presto::ArgProcessor - Term::ShellUI sub-class

=head1 VERSION

version 0.004

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

