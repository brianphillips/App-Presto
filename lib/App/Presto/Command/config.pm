package App::Presto::Command::config;

# ABSTRACT: Config-related commands

use Moo;
with 'App::Presto::InstallableCommand','App::Presto::CommandHasHelp';

sub install {
    my $self = shift;
    $self->term->add_commands(
        {
            config => {
                desc => 'get/set config values',
                minargs => 0,
                maxargs => 2,
                args    => [ sub { return [$self->config->keys] } ],
                proc    => sub {
                    if(@_ == 1){
                        printf "%s=%s\n", $_[0], $self->config->get( $_[0] );
                    } elsif(@_ == 2){
                        if($_[0] eq '--unset'){
                            $self->config->unset( $_[1] );
                        } else {
                            $self->config->set(@_);
                        }
                    } else {
                        foreach my $k($self->config->keys){
                            printf "%s=%s\n", $k, $self->config->get( $k );
                        }
                    }
                },
            },
        }
    );
}

sub help_categories {
    return {
        desc => 'Get/Set/List config values',
        cmds => [qw(config)],
    };
}

1;
