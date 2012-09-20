package App::Presto::Command::config;

# ABSTRACT: Config-related commands

use Moo;
with 'App::Presto::InstallableCommand','App::Presto::CommandHasHelp','App::Presto::WithPrettyPrinter';

sub install {
    my $self = shift;
    my %opts = (minargs => 0, maxargs => 1);
    $self->term->add_commands(
        {
            config => {
                desc => 'get/set config values',
                cmds => {
                    binmode => {
                        desc => 'control how output is encoded and input is decoded',
                        args => 'anything that will work in binmode(STDOUT, :encoding(<CONFIG VALUE>)) (i.e. "utf8")',
                        proc => $self->_mk_proc_for_config(
                            'binmode',
                            sub {
                                my $e = shift;
                                eval {
                                    binmode( STDOUT, ":encoding($e)" );
                                    binmode( STDIN,  ":encoding($e)" );
                                    1;
                                } or do {
                                    warn $@;
                                };
                            }
                        ),
                        %opts,
                    },
                    verbose => {
                        desc => 'dump request/response to STDOUT',
                        args => 'boolean, either 0 or 1',
                        proc => $self->_mk_proc_for_config('verbose'),
                        %opts,
                    },
                    deserialize_response => {
                        desc =>
                          'parse response body for better pretty-printing',
                        args => 'boolean, either 0 or 1',
                        proc => $self->_mk_proc_for_config('verbose'),
                        %opts,
                    },
                    pretty_printer => {
                        desc => 'Used for dumping data structures to STDOUT',
                        args => sub {
                            [ 'JSON', 'Data::Dumper', 'Data::Dump', 'YAML' ];
                        },
                        proc => $self->_mk_proc_for_config('pretty_printer'),
                        %opts,
                    },
                    '--unset' => {
                        desc    => 'Unset config value',
                        minargs => 1,
                        maxargs => 1,
                        args    => sub {
                            [ $self->config->keys ];
                        },
                        proc => sub {
                            $self->config->unset(shift);
                        },
                    },
                },
                proc => sub {
                    print $self->pretty_print( $self->config->config );
                  }
            },
        }
    );
}

sub help_categories {
    return {
        desc => 'Get/Set/List config values',
        cmds => [sort map { "config $_" } 'pretty_printer', 'deserialize_response', 'verbose', 'binmode','--unset'],
    };
}

sub _mk_proc_for_config {
    my $self = shift;
    my $key  = shift;
    my $cb   = shift;
    return sub {
        if(@_ == 1){
            $self->config->set($key, $_[0]);
            $cb->($_[0]) if($cb);
        } else {
            print $self->pretty_print( { $key => $self->config->get( $key ) } );
        }
    };
}

1;
