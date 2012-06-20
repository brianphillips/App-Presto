package App::REST::CLI::Command::HTTP;

use strict;
use warnings;
use Moo;
with 'App::REST::CLI::InstallableCommand';

sub install {
    my $self = shift;
    my $config = $self->config;
    my $client = $self->client;
    $self->term->add_commands(
        {
            form   => {
                proc => sub {
                    my $uri = $client->_append_query_params('', @_);
                    $uri =~ s{^\?}{};
                    print "$uri\n";
                }
            },
            GET => {
                proc => sub {
                    $client->GET(@_);
                    if($config->{verbose} || 1){
                        my $response = $client->response;
                        print _dump_request_response( $response->request, $response );
                    }
                },
            },
            POST   => {
                proc => sub {
                    $client->POST(@_);
                    if($config->{verbose} || 1){
                        my $response = $client->response;
                        print _dump_request_response( $response->request, $response );
                    }
                },
            },
            PUT    => {},
            DELETE => {},
        }
    );
}

sub _dump_request_response {
    my($request,$response) = @_;
    return sprintf(<<'_OUT_', $request->as_string, $response->as_string);
----- REQUEST  -----
%s
----- RESPONSE -----
%s
-----   END    -----
_OUT_
}

1;
