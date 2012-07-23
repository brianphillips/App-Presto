use strict;
use warnings;
use Test::More;
use File::Basename;
use App::Presto::Config;
use File::Path qw(remove_tree);

sub capture_warnings (&) {
    my $sub = shift;
    my @warnings;
    local $SIG{__WARN__} = sub { chomp(my @w = @_); push @warnings, @w };
    $sub->();
    return @warnings;
}

my(undef, $d) = fileparse(__FILE__);
my $EMPTY = $d . 'empty-config';
my $EXISTING = $d . 'config';

subtest 'empty config' => sub {
    local $ENV{APP_REST_CLI_DIR} = $EMPTY;

    #pre-clear
    remove_tree( $EMPTY, { keep_root => 1 } );

    my $config = App::Presto::Config->new( endpoint => 'http://myserver.com' );
    my @warnings = capture_warnings {
        like $config->endpoint_dir, qr{myserver},
          'config dir reflects endpoint name';
    };

    like $warnings[0], qr{creating directory},
      'warnings about creating directory';

    # empty it out again
    remove_tree( $EMPTY );
};

subtest 'existing config' => sub {
    local $ENV{APP_REST_CLI_DIR} = $EXISTING;

    my $config = App::Presto::Config->new( endpoint => 'http://myserver.com' );
    my @warnings = capture_warnings {
        like $config->endpoint_dir, qr{myserver},
          'config dir reflects endpoint name';
    };

    ok !@warnings, 'no warnings' or diag explain $config, \@warnings;

    like $config->file('foo'), qr{/foo}, 'file has correct name';
    $config->set(endpoint => 'http://anotherserver.com');
    like $config->endpoint_dir, qr{anotherserver}, 'new endpoint == new endpoint_dir';
};

subtest 'new endpoint' => sub {
    local $ENV{APP_REST_CLI_DIR} = $EXISTING;

    my $config = App::Presto::Config->new( endpoint => 'http://myserver.com' );
    my @warnings = capture_warnings {
        like $config->endpoint_dir, qr{myserver},
          'config dir reflects endpoint name';
    };

    ok !@warnings, 'no warnings' or diag explain $config, \@warnings;
    is $config->get('foo'), 1, 'loaded correctly';
    diag explain $config->config;

    like $config->file('foo'), qr{/foo}, 'file has correct name';
    $config->set(endpoint => 'http://anotherserver.com');
    like $config->endpoint_dir, qr{anotherserver}, 'new endpoint == new endpoint_dir';
};

done_testing;

