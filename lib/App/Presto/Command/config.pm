package App::Presto::Command::config;
BEGIN {
  $App::Presto::Command::config::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::Command::config::VERSION = '0.001';
}

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

__END__
=pod

=head1 NAME

App::Presto::Command::config - Config-related commands

=head1 VERSION

version 0.001

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

