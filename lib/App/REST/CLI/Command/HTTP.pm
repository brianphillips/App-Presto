package App::REST::CLI::Command::HTTP;

use strict;
use warnings;
use Moo;
#use REST::Client;

sub install {
    my $self = shift;
    $self->term->add_commands(
        GET => {
            proc => sub {
            },
        },
        POST => {
        },
        PUT => {
        },
        DELETE => {
        },
    );
}

1;
