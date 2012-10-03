package App::Presto::Client::ContentHandlers::JSON;
BEGIN {
  $App::Presto::Client::ContentHandlers::JSON::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::Client::ContentHandlers::JSON::VERSION = '0.007';
}

# ABSTRACT: Handles (de)serializing of JSON requests/responses

use Moo;
my $HAS_JSON;
BEGIN {
	eval 'use JSON; $HAS_JSON = 1;'
}
sub can_deserialize {
	my $self = shift;
	my $content_type = shift;
	return unless $HAS_JSON;
	return $content_type =~ m{^application/json}i;
}

sub deserialize {
	my $self = shift;
	my $content = shift;
	my $ref;
	eval { $ref = JSON::decode_json($content) || 1 } or do {
		warn "Unable to parse JSON: $@";
	};
	return $ref;
}

sub can_serialize {
	my $self = shift;
	my $content_type = shift;
	return unless $HAS_JSON;
	return $content_type =~ m{^application/json}i;
}
sub serialize {
	my $self = shift;
	my $data = shift;
	return JSON::encode_json($data);
}

1;

__END__
=pod

=head1 NAME

App::Presto::Client::ContentHandlers::JSON - Handles (de)serializing of JSON requests/responses

=head1 VERSION

version 0.007

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

