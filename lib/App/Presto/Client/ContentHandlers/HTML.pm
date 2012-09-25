package App::Presto::Client::ContentHandlers::HTML;

# ABSTRACT: Handles deserializing of HTML responses

use Moo;
my $HAS_HTML_FORMATTEXT_WITHLINKS;
BEGIN {
    eval 'use HTML::FormatText::WithLinks; $HAS_HTML_FORMATTEXT_WITHLINKS = 1;'
}

sub can_deserialize {
	my $self = shift;
	my $content_type = shift;
	return unless $HAS_HTML_FORMATTEXT_WITHLINKS;
	return $content_type =~ m{^text/html}i;
}

sub deserialize {
	my $self = shift;
	my $content = shift;
	my $text;
	eval { $text = HTML::FormatText::WithLinks->format_string($content) || 1 } or do {
		warn "Unable to parse HTML: $@";
	};
	return $text;
}

sub can_serialize { 0 }

1;
