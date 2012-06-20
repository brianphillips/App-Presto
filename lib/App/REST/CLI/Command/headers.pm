package App::REST::CLI::Command::headers;

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
                proc    => sub {
                    my ( $username, $password ) = @_;
                    $client->set_header(
                        Authorization => sprintf( 'Basic %s',
                            MIME::Base64::encode( "$username:$password", '' ) )
                    );
                },
            },
            type => {
                minargs => 1,
                proc    => sub {
                    $client->set_header( 'Content-Type', shift );
                },
            },
            headers => {
                maxargs => 0,
                alias   => 'header',
            },
            header => {
                proc => sub {
                    my $header = shift;
                    my @args   = @_;
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
                    elsif (@args) {      # set
                        $header =~ s/:$//
                          ; # to allow pasting of an actual HTTP header from the dump
                        my $value = join ' ', @args;
                        $client->set_header( $header, $value );
                    }
                    else {    # get
                        printf( "Header: %s: %s\n",
                            $header, $client->get_header($header) );
                    }
                },
            },
        }
    );

}

1;
