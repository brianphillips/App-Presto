package App::REST::CLI::Client;

use strict;
use warnings;
use Moo;
use REST::Client;
use URI;
use URI::QueryParam;

has context => ( is => 'lazy' );
sub _build_context {
    require App::REST::CLI;
    return App::REST::CLI->instance;
}
has _rest_client => ( is => 'lazy', );
sub _build__rest_client {
    my $self    = shift;
    return REST::Client->new;
}

sub all_headers {
    my $self = shift;
    my $headers = $self->_rest_client->{_headers} || {};
    return %$headers;
}

sub set_header {
    my $self = shift;
    return $self->_rest_client->addHeader(@_);
}

sub get_header {
    my $self    = shift;
    my $header  = shift;
    my $headers = $self->_rest_client->{_headers} || {};
    return exists $headers->{$header} ? $headers->{$header} : undef;
}

sub clear_headers {
    my $self = shift;
    $self->_rest_client->{_headers} = {};
    return;
}

sub GET {
    my $self = shift;
    my $uri  = $self->_make_uri(@_);
    $self->_rest_client->GET($uri);
}
sub POST {
    my $self = shift;
    my $uri  = $self->_make_uri(shift);
    $self->_rest_client->POST($uri, shift);
}

sub _make_uri {
    my $self      = shift;
    my $local_uri = shift;
    my @args      = @_;
    my $context   = $self->context;

    my $endpoint = $context->config->endpoint;
    $endpoint .= '*' unless $endpoint =~ m/\*/;
    $endpoint =~ s{\*}{$local_uri};

    my $u = $self->_append_query_params( $endpoint, @args );
    return "$u";
}

sub _append_query_params {
    my $self = shift;
    my @args = @_;
    my $u = URI->new(shift);
    foreach my $next (@args) {
        $u->query_param_append( split( /=/, $next, 2 ) );
    }
    return $u;
}

sub response {
    return shift->_rest_client->{_res} || undef;
}

1;
