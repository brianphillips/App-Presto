package App::REST::CLI::Command::shell;

use strict;
use warnings;
use App::REST::CLI -command;
use Term::ShellUI;
use LWP::UserAgent;
use URI;
use URI::QueryParam;
use 5.012;

sub execute {
    my $self = shift;
    my ($options, $args) = @_;
    my %config;
    $config{endpoint} = $args->[0] if @$args;
    my %headers;
    my $ua = LWP::UserAgent->new;
    my $term = Term::ShellUI->new(
        app => "REST",
        commands => {
            "set" => {
                cmds => {
                    config => {
                        minargs => 2,
                        maxargs => 2,
                        proc => sub {
                            $config{$_[0]} = $_[1];
                        },
                    },
                    header => {
                        minargs => 2,
                        maxargs => 2,
                        proc => sub {
                            $headers{$_[0]} = $_[1];
                        },
                    },
                }
            },
            show => {
                cmds => {
                    config => {
                        minargs => 0,
                        maxargs => 1,
                        proc => sub {
                            my @h = @_ ? @_ : sort keys %config;
                            foreach my $k(@h){
                                say "$k: [$config{$k}]";
                            }
                        },
                    },
                    header => {
                        minargs => 1,
                        alias => 'headers',
                    },
                    headers => {
                        minargs => 0,
                        maxargs => 1,
                        proc => sub {
                            my @h = @_ ? @_ : sort keys %headers;
                            foreach my $k(@h){
                                if(exists $headers{$k}){
                                    say "$k: [$headers{$k}]";
                                } else {
                                    say "* unknown header key $k";
                                }
                            }
                        },
                    }
                }
            },
            "GET" => {
                desc    => "perform a GET",
                proc => sub {
                    my $url_part = shift;
                    (my $url = $config{endpoint}) =~ s/\*|$/$url_part/;
                    my $uri = URI->new($url);
                    foreach my $pair(@_){
                        my($param,$val) = split(/=/, $pair, 2);
                        $uri->query_param_append($param, $val);
                    }
                    my $response = $ua->get($uri, %headers);
                    if($config{verbose} || !$response->is_success){
                        say $response->request->as_string;
                        say $response->as_string;
                    } else {
                        say $response->decoded_content;
                    }
                },
            },
            "exit" => {
                desc    => "Quit this program",
                maxargs => 0,
                method  => sub { shift->exit_requested(1); },
            }
        },
        history_file => '~/.shellui-synopsis-history',
    );
    if(!$config{endpoint}){
        local $|;
        print "REST endpoint? ";
        chomp(my $endpoint = <STDIN>);
        $config{endpoint} = $endpoint;
    }
    $term->prompt( sub { $config{endpoint} . '> ' } );
    $term->run;
}

1;
