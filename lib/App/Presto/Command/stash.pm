package App::Presto::Command::stash;
BEGIN {
  $App::Presto::Command::stash::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::Command::stash::VERSION = '0.005';
}

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
                args    => [ sub { return [keys %{ $self->stash }] } ],
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

__END__
=pod

=head1 NAME

App::Presto::Command::stash - REST stash-related commands

=head1 VERSION

version 0.005

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

