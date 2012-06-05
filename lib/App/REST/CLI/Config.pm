package App::REST::CLI::Config;

use Moo;

has config => (
    is => 'ro',
    isa => sub { die "not a HashRef" if ref($_[0])  ne 'HASH'; },
    default => sub { +{} },
);

sub set {
    my $self = shift;
    my $key  = shift;
    my $value = shift;
    $self->config->{$key} = $value;
    return;
}

sub get {
    my $self = shift;
    my $key  = shift;
    return $self->config->{$key};
}

sub keys {
    my $self = shift;
    return keys %{ $self->config };
}

1;
