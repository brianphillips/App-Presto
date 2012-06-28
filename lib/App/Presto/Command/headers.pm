package App::Presto::Command::headers;

# ABSTRACT: HTTP header-related commands

use strict;
use warnings;
use Moo;
use MIME::Base64;
with 'App::Presto::InstallableCommand','App::Presto::CommandHasHelp';

sub install {
    my $self = shift;
    my $config = $self->config;
    my $client = $self->client;
    $self->term->add_commands(
        {
            authorization => {
                minargs => 2,
                maxargs => 2,
                desc => 'Set basic auth username/password',
                args => [sub { '[username]' },sub { '[password]' } ],
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
                desc => 'Set content-type header',
                proc    => sub {
                    $client->set_header( 'Content-Type', shift );
                },
            },
            headers => {
                maxargs => 0,
                alias   => 'header',
            },
            header => {
                desc => 'get/set/list/clear HTTP headers',
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
                    elsif ( $header eq '-clear' ) {
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

sub help_categories {
    return {
        desc => 'Configure various HTTP headers',
        cmds => [qw(authorization headers type)],
    };
}

1;
