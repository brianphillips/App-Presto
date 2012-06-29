package App::Presto::Command::HTTP;
BEGIN {
  $App::Presto::Command::HTTP::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::Command::HTTP::VERSION = '0.001';
}

# ABSTRACT: HTTP-related commands

use strict;
use warnings;
use Moo;
with 'App::Presto::InstallableCommand', 'App::Presto::CommandHasHelp';

sub install {
    my $self = shift;
    my $config = $self->config;
    my $client = $self->client;
    $self->term->add_commands(
        {
            form   => {
                proc => sub {
                    my @query;
                    foreach my $kv(@_){
                        my($k,$v) = split(/=/, $kv, 2);
                        push @query, $k, $v || '';
                    }
                    my $uri = $client->_append_query_params('', @query);
                    $uri =~ s{^\?}{};
                    print "$uri\n";
                }
            },
            GET => {
                desc => 'perform a GET HTTP action',
                proc => sub {
                    $client->GET(@_);
                    $self->handle_response($client);
                },
            },
            POST   => {
                desc => 'perform a POST HTTP action',
                proc => sub {
                    $client->POST(@_);
                    $self->handle_response($client);
                },
            },
            PUT    => {
                desc => 'perform a PUT HTTP action',
                proc => sub {
                    $client->PUT(@_);
                    $self->handle_response($client);
                },
            },
            DELETE => {
                desc => 'perform a DELETE HTTP action',
                proc => sub {
                    $client->DELETE(@_);
                    $self->handle_response($client);
                },
            },
            HEAD => {
                desc => 'perform a HEAD HTTP action',
                proc => sub {
                    $client->HEAD(@_);
                    $self->handle_response($client);
                },
            },
        }
    );
}

sub handle_response {
    my $self = shift;
    my $client = shift;
    my $response = $client->response;
    my $config = $self->config;
    if ( $config->get('verbose') ) {
        print _dump_request_response( $response->request, $response );
    }
    if ( $response->content_length ) {
        if ( $config->get('deserialize_response') ) {
            my $data = $client->response_data;
            $self->_pretty_print_data($data);
        } elsif ( !$config->get('verbose') ) {    # don't print just the content a second time...
            print $response->content;
            print "\n";
        }
    } elsif ( !$config->get('verbose') ) {
        print $response->as_string, "\n";
    }
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

sub _deserialize_response {
    my $response = shift;
    return $response->content;
}

sub help_categories {
    return {
        desc => 'Various HTTP verb commands',
        cmds => [qw(GET POST HEAD PUT DELETE)],
    };
}

my %PRETTY_PRINTERS = (
    'Data::Dump' => sub {
        require Data::Dump;
        return Data::Dump::dump(shift) . "\n";
    },
    'Data::Dumper' => sub {
        require Data::Dumper;
        no warnings 'once';
        local $Data::Dumper::Sortkeys = 1;
        return Data::Dumper::Dumper(shift);
    },
    'JSON' => sub { require JSON; return JSON->new->pretty->encode(shift) },
    'YAML' => sub { require YAML; return YAML::Dump(shift) },
);
sub _pretty_print_data {
    my $self = shift;
    my $data = shift;
    my $pretty_printer = $PRETTY_PRINTERS{$self->config->get('pretty_printer') || ''} || $PRETTY_PRINTERS{'Data::Dumper'};
    print $pretty_printer->($data);
}

1;

__END__
=pod

=head1 NAME

App::Presto::Command::HTTP - HTTP-related commands

=head1 VERSION

version 0.001

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

