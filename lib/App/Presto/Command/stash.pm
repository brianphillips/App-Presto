package App::Presto::Command::stash;

# ABSTRACT: REST stash-related commands

use Moo;
use Data::Dumper;
with 'App::Presto::InstallableCommand', 'App::Presto::CommandHasHelp', 'App::Presto::WithPrettyPrinter';

sub install {
    my $self = shift;
    $self->term->add_commands(
        {
            stash => {
                desc => 'get/set stash values',
                minargs => 0,
                maxargs => 2,
                args    => [ sub { return [$self->config->keys] } ],
                proc    => sub {
                    if(@_ == 1){
                        print $self->pretty_print( { $_[0] => $self->stash($_[0]) } );
                    } elsif(@_ == 2){
                        if($_[0] eq '--unset'){
                            $self->_stash->unset( $_[1] );
                        } else {
                            $self->stash(@_);
                        }
                    } else {
                        print $self->pretty_print( $self->stash );
                    }
                },
            },
        }
    );
}

sub help_categories {
    return {
        desc => 'Get/Set/List stash values',
        cmds => [qw(stash)],
    };
}

1;
