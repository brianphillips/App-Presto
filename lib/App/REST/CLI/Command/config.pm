package App::REST::CLI::Command::config;

use Moo;
with 'App::REST::CLI::InstallableCommand';

sub install {
    my $self = shift;
    $self->term->add_commands(
        {
            config => {
                minargs => 0,
                maxargs => 2,
                proc    => sub {
                    if(@_ == 1){
                        printf "%s=%s\n", $_[0], $self->config->get( $_[0] );
                    } elsif(@_ == 2){
                        $self->config->set(@_);
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

1;
