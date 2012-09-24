package App::Presto::Client::ContentHandlers::XMLSimple;
BEGIN {
  $App::Presto::Client::ContentHandlers::XMLSimple::AUTHORITY = 'cpan:BPHILLIPS';
}
{
  $App::Presto::Client::ContentHandlers::XMLSimple::VERSION = '0.005';
}

# ABSTRACT: Handles (de)serializing of XML requests/responses

use Moo;
my $HAS_XML_SIMPLE;
BEGIN {
	eval 'use XML::Simple; $HAS_XML_SIMPLE = 1;';
	warn $@ if $@;
}
sub can_deserialize {
	my $self = shift;
	my $content_type = shift;
	return unless $HAS_XML_SIMPLE;
	return $content_type =~ m{^application/xml}i;
}

sub deserialize {
	my $self = shift;
	my $content = shift;
	my $ref;
	eval { $ref = XMLin($content) || 1 } or do {
		warn "Unable to parse XML: $@";
	};
	return $ref;
}

sub can_serialize {
	my $self = shift;
	my $content_type = shift;
	return unless $HAS_XML_SIMPLE;
	return $content_type =~ m{^application/xml}i;
}
sub serialize {
	my $self = shift;
	my $data = shift;
	return XMLout($data);
}

1;

__END__
=pod

=head1 NAME

App::Presto::Client::ContentHandlers::XMLSimple - Handles (de)serializing of XML requests/responses

=head1 VERSION

version 0.005

=head1 AUTHOR

Brian Phillips <bphillips@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Brian Phillips and Shutterstock Images (http://shutterstock.com).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

