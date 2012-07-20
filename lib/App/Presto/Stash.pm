package App::Presto::Stash;

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
