package App::Presto::Client;

# ABSTRACT: The REST client

use strict;
use warnings;
use Moo;
use REST::Client;
use URI;
use URI::QueryParam;
use Module::Pluggable
  instantiate => 'new',
  sub_name    => 'content_handlers',
  search_path => ['App::Presto::Client::ContentHandlers'];

has config => ( is => 'ro', required => 1 );
has _rest_client => ( is => 'lazy', );

sub _build__rest_client {
	my $self = shift;
	return REST::Client->new;
}

sub all_headers {
	my $self = shift;
	my $headers = $self->_rest_client->{_headers} || {};
	return %$headers;
}

sub set_header {
	my $self = shift;
	my($name, $value) = @_;
	return $self->_rest_client->addHeader(lc $name, $value);
}

sub get_header {
	my $self    = shift;
	my $header  = lc shift;
	my $headers = $self->_rest_client->{_headers} || {};
	return exists $headers->{$header} ? $headers->{$header} : undef;
}

sub clear_header {
	my $self = shift;
	my $name = lc shift;
	return delete $self->_rest_client->{_headers}->{$name};
}

sub clear_headers {
	my $self = shift;
	%{$self->_rest_client->{_headers} || {}} = ();
	return;
}

sub GET {
	my $self = shift;
	my $uri  = $self->_make_uri(@_);
	my $existing_content_type = $self->clear_header('content-type'); # GET shouldn't have a content type
	my $response = $self->_rest_client->GET($uri);
	$self->set_header('content-type', $existing_content_type) if $existing_content_type;
	return $response;
}

sub HEAD {
	my $self = shift;
	my $uri  = $self->_make_uri(@_);
	my $existing_content_type = $self->clear_header('content-type'); # HEAD shouldn't have a content type
	my $response = $self->_rest_client->HEAD($uri);
	$self->set_header('content-type', $existing_content_type) if $existing_content_type;
	return $response;
}

sub DELETE {
	my $self = shift;
	my $uri  = $self->_make_uri(@_);
	my $existing_content_type = $self->clear_header('content-type'); # DELETE shouldn't have a content type
	my $response = $self->_rest_client->DELETE($uri);
	$self->set_header('content-type', $existing_content_type) if $existing_content_type;
	return $response;
}

sub POST {
	my $self = shift;
	my $uri  = $self->_make_uri(shift);
	$self->_rest_client->POST( $uri, shift );
}

sub PUT {
	my $self = shift;
	my $uri  = $self->_make_uri(shift);
	$self->_rest_client->PUT( $uri, shift );
}

sub _make_uri {
	my $self      = shift;
	my $local_uri = shift;
	my @args      = @_;
	my $config    = $self->config;

	my $endpoint;
	$local_uri = '/' if ! defined $local_uri;
	if ( $local_uri =~ m{^https?://} ) {
		$endpoint = $local_uri;
	} else {
		$endpoint = $config->endpoint;
		$endpoint .= '*' unless $endpoint =~ m/\*/;
		$endpoint =~ s{\*}{$local_uri};
	}

	my $u = $self->_append_query_params( $endpoint, @args );
	return "$u";
}

sub _append_query_params {
	my $self = shift;
	my @args = @_;
	my $u    = URI->new(shift);
	foreach my $next (@args) {
		$u->query_param_append( split( /=/, $next, 2 ) );
	}
	return $u;
}

sub response {
	return shift->_rest_client->{_res} || undef;
}

sub has_response_content {
	my $self = shift;
	return $self->response->content_length
	  || length( $self->response->content );
}

sub response_data {
	my $self     = shift;
	my $response = $self->response;
	if ( my $content_type = $response->header('Content-type') ) {
		foreach my $h ( $self->content_handlers ) {
			if ( $h->can_deserialize($content_type) ) {
				return $h->deserialize( $response->content );
			}
		}
	}
	return $response->decoded_content;
}

1;
