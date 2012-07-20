package App::Presto::ShellUI;

# ABSTRACT: Term::ShellUI sub-class

use strict;
use warnings;
use Regexp::Common qw(balanced);
use Moo;
extends 'Term::ShellUI';

foreach my $m(qw(readline GetHistory)){
	no strict 'refs';
	*$m = sub { my $self = $_[0]; my $target = $self->{term}->can($m); $_[0] = $self->{term}; goto $target };
}

sub call_command {
	my $self = shift;
	my($cmd) = @_;
	my $args = $cmd->{args};
	eval {
			foreach my $i ( 0 .. $#{$args} )
			{
					if ( $args->[$i] =~ m{^#} ) {
							splice( @$args, $i );    # everything else is a comment
							last;
					} else {
							$args->[$i] =~ s[(\$$RE{balanced}{-keep})][$self->_expand_param(substr($2,1,-1),$1)]eg;
					}
			}
			1;
	} or do {
			warn "Error preparsing args @$args: $@";
	};
	return $self->SUPER::call_command(@_);
}

sub _expand_param {
	my $self = shift;
	my $param = shift;
	my $orig  = shift;
	my $replacement = '';
	if($param =~ m/^(BODY|HEADER)\b(.*)/){
		$replacement = $self->_expand_response_param($1,$2);
	} elsif($param =~ m/^STASH($RE{balanced}{-parens => '[]'})/){
		$replacement = App::Presto->instance->stash(substr($1,1,-1));
	}
	return defined $replacement ? $replacement : $orig;
}

sub _expand_response_param {
	my $self = shift;
	my $section = shift;
	my $sub_section = shift;
	my $client = App::Presto->instance->client;
	if($section eq 'HEADER' && $sub_section =~ m/($RE{balanced}{-parens => '[]'})/){
		return $client->response->header(substr($1,1,-1));
	} elsif($section eq 'BODY'){
		if(!$sub_section){
			return $client->response->content;
		} elsif( $sub_section =~ m{^/} ){
			require Data::DPath;
			my @matches = Data::DPath::Path->new(path => $sub_section)->match($client->response_data);
			return @matches > 1 ? \@matches : $matches[0];
		}
	} 
}

1;
