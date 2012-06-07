package App::REST::CLI::Command::HTTP;

use strict;
use warnings;
use Moo;
use MIME::Base64;
with 'App::REST::CLI::InstallableCommand';

sub install {
    my $self = shift;
    my $config = $self->config;
    my $client = $self->client;
    $self->term->add_commands(
        {
            authorization => {
                minargs => 2,
                maxargs => 2,
                proc => sub {
                    my($username, $password) = @_;
                    $client->set_header(
                        Authorization => sprintf( 'Basic %s',
                            MIME::Base64::encode( "$username:$password", '' ) )
                    );
                },
            },
            type => {
                minargs => 1,
                proc => sub {
                    $client->set_header('Content-Type', shift );
                },
            },
            form   => {
                proc => sub {
                    my $uri = $client->_append_query_params('', @_);
                    $uri =~ s{^\?}{};
                    print "$uri\n";
                }
            },
            headers => {
                maxargs => 0,
                alias => 'header',
            },
            header => {
                proc  => sub {
                    my $header = shift;
                    if ( !$header ) {    # print all
                        my %headers = $client->all_headers;
                        print "Headers:\n";
                        foreach my $h ( keys %headers ) {
                            printf " - %s: %s\n", $h, $headers{$h};
                        }
                    }
                    elsif ( $header eq 'clear' ) {
                        $client->clear_headers;
                    }
                    elsif ( defined( my $value = shift ) ) {    # set
                        $client->set_header( $header, $value );
                    }
                    else {                                      # get
                        printf( "Header: %s: %s\n",
                            $header, $client->get_header($header) );
                    }
                },
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
