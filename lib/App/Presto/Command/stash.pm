package App::Presto::Command::stash;
BEGIN {
  $App::Presto::Command::stash::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::Command::stash::VERSION = '0.001';
}

# ABSTRACT: REST stash-related commands

use Moo;
use Data::Dumper;
with 'App::Presto::InstallableCommand', 'App::Presto::CommandHasHelp';

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
                        printf "%s=%s\n", $_[0], $self->stash( $_[0] );
                    } elsif(@_ == 2){
                        if($_[0] eq '--unset'){
                            $self->_stash->unset( $_[1] );
                        } else {
                            $self->stash(@_);
                        }
                    } else {
												no warnings 'once';
												local $Data::Dumper::Sortkeys=1;
												print Dumper $self->stash;
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

App::Presto::Command::stash - REST stash-related commands

=head1 VERSION

version 0.001

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

