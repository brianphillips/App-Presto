package App::Presto::PrettyPrinter;

# ABSTRACT: abstracted pretty-printer support

use strict;
use warnings;
use Moo;

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

has config => (
    is => 'lazy',
);
sub _build_config {
    return App::Presto->instance->config;
}

sub pretty_print {
    my $self = shift;
    my $data = shift;
    my $driver = $self->config->get('pretty_printer');
    my $printer = $PRETTY_PRINTERS{$driver} || $PRETTY_PRINTERS{'Data::Dumper'};
    return $printer->($data);
}

1;
