package App::Presto::Command::HTTP;

use strict;
use warnings;
use Moo;
with('App::Presto::InstallableCommand', 'App::Presto::CommandHasHelp');

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
                desc => 'perform a GET HTTP action',
                proc => sub {
                    $client->GET(@_);
                    if($config->{verbose} || 1){
                        my $response = $client->response;
                        print _dump_request_response( $response->request, $response );
                    }
                },
            },
            POST   => {
                desc => 'perform a POST HTTP action',
                proc => sub {
                    $client->POST(@_);
                    if($config->{verbose} || 1){
                        my $response = $client->response;
                        print _dump_request_response( $response->request, $response );
                    }
                },
            },
            PUT    => {
                desc => 'perform a PUT HTTP action',
            },
            DELETE => {
                desc => 'perform a DELETE HTTP action',
            },
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

sub help_categories {
    return {
        desc => 'Various HTTP verb commands',
        cmds => [qw(GET POST PUT DELETE)],
    };
}

1;
