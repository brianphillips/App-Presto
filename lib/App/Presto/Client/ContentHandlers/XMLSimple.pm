package App::Presto::Client::ContentHandlers::XMLSimple;

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
