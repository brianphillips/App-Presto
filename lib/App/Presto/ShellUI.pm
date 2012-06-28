package App::Presto::ShellUI;

# ABSTRACT: Term::ShellUI sub-class

use strict;
use warnings;
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
	foreach my $i(0..$#{ $args }){
		if($args->[$i] =~ m{^\$(.+)}){
			$args->[$i] = $self->_expand_param($1);
		} else {
			$args->[$i] =~ s[\{\{\$(.+?)\}\}][$self->_expand_param($1)]eg;
		}
	}
	return $self->SUPER::call_command(@_);
}

sub _expand_param {
	my $self = shift;
	my $param = shift;
	my $replacement = '';
	if($param =~ m/^(BODY|HEADER)\b(.*)/){
		$replacement = $self->_expand_response_param($1,$2);
	}
	return $replacement;
}

sub _expand_response_param {
	my $self = shift;
	my $section = shift;
	my $sub_section = shift;
	my $client = App::Presto->instance->client;
	if($section eq 'HEADER' && $sub_section =~ m/\{([^\}]+)\}/){
		return $client->response->header($1);
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
