package App::Presto::Config;

# ABSTRACT: Manage configuration for a given endpoint

use Moo;
use JSON qw(decode_json encode_json);
use File::HomeDir;
use File::Path qw(make_path);

has endpoint => (
    is => 'rw',
    required => 1,
);
has config => (
    is => 'lazy',
    clearer => 'reload',
    isa => sub { die "not a HashRef" if ref($_[0])  ne 'HASH'; },
);
sub _build_config {
    my $self = shift;
    my $config_file = $self->file('config.json');
    if (! -e $config_file ) {
        warn "creating new config file: $config_file\n";
        open( my $fh, '>', $config_file ) or die "Unable to open $config_file for writing: $!";
        print $fh encode_json({});
        close $fh;
    }

    my $config;
    eval {
        local $/;
        open( my $fh, '<', $config_file ) or die "Unable to open $config_file for reading: $!";
        my $json_text = <$fh>;
        $config = decode_json( $json_text || '{}' );
        1;
    } or do {
        warn "Ignoring invalid config file $config_file: $@\n";
        $config = {};
    };
    return $config;
}

has endpoint_dir => (
    is => 'lazy',
);

sub _build_endpoint_dir {
    my $self = shift;
    my $root = $ENV{APP_REST_CLI_DIR} || sprintf('%s/.app-rest-cli', File::HomeDir->my_home);
    (my $endpoint_dir = lc $self->endpoint) =~ s/\W+/-/g;
    my $dir = sprintf( '%s/%s', $root, $endpoint_dir);
    if(!-d $dir){
        warn "creating directory $dir\n";
        make_path($dir);
    }
    return $dir;
}

sub file {
    my $self = shift;
    (my $file = shift) =~ s{^[\./]+}{}g; # remove leading dots or slashes
    return sprintf('%s/%s', $self->endpoint_dir, $file);
}

sub set {
    my $self = shift;
    my $key  = shift;
    my $value = shift;
    if($key eq 'endpoint'){
        return $self->endpoint($value);
    }
    if(!defined $value){
        delete $self->config->{$key};
    } else {
        $self->config->{$key} = $value;
    }
    eval {
        $self->write_config;
        1;
    } or do {
        warn "unable to persist config: $@\n";
    };
    return;
}
sub unset {
    my $self = shift;
    return $self->set($_[0],undef);
}

sub get {
    my $self = shift;
    my $key  = shift;
    return $self->endpoint if $key eq 'endpoint';
    return $self->config->{$key};
}

sub keys {
    my $self = shift;
    return keys %{ $self->config };
}

sub write_config {
    my $self = shift;
    my $config_file = $self->file('config.json');
    open(my $fh, '>', $config_file) or die "Unable to open $config_file for writing: $!";
    print $fh encode_json($self->config);
    close $fh;
    return;
}


1;
