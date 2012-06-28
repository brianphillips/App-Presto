package App::Presto::Client::ContentHandlers::JSON;

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
