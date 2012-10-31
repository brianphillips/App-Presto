package App::Presto::Stash;
BEGIN {
  $App::Presto::Stash::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::Stash::VERSION = '0.008';
}

# ABSTRACT: Presto stash

use Moo;

{
	my $stash = {};
	sub get {
		my $self = shift;
		my $key  = shift;
		return exists $stash->{$key} ? $stash->{$key} : undef;
	}
	sub set {
		my $self = shift;
		my($k,$v) = @_;
		return $stash->{$k} = $v;
	}
	sub unset {
		my $self = shift;
		my $k = shift;
		return delete $stash->{$k};
	}

	sub stash {
		my $self = shift;
		if(@_ == 2){
			return $self->set(@_);
		} elsif(@_ == 1){
			return $self->get(@_);
		} else {
			return $stash;
		}
	}
}

1;

__END__
=pod

=head1 NAME

App::Presto::Stash - Presto stash

=head1 VERSION

version 0.008

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

