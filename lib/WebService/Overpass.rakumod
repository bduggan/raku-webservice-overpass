unit class WebService::Overpass;

use HTTP::Tiny;
use Log::Async;

logger.untapped-ok = True;

has $.url = 'https://overpass-api.de/api/interpreter';
has $.ua = HTTP::Tiny.new;
has $.logger = logger;

method query($data) {
  debug "Running overpass query";
  debug "> $_" for $data.lines;
  my $res = HTTP::Tiny.new.post: $!url, :content(%(:$data));
  unless $res<success> {
    die "Error querying Overpass API: $res<status> $res<reason>";
  }
  my $out = $res<content>.decode;
  $out;
}

=begin pod

=head1 NAME

WebService::Overpass - A simple interface to the Overpass API

=head1 SYNOPSIS

  use WebService::Overpass;

  my $overpass = WebService::Overpass.new;

  $overpass.logger.send-to: $*ERR; # optional

  my $data = q:to/END/;
  [out:json];
  node(1);
  out;
  END

  my $res = $overpass.query($data);

  say $res;

=head1 DESCRIPTION

This module provides a simple interface to the Overpass API.

=head1 METHODS

=head2 query

  method query($data) returns Str

This method sends a query to the Overpass API and returns the result.

The C<$data> parameter should be a string containing the query to be executed.

=head1 ATTRIBUTES

=head2 url

  has $.url = 'https://overpass-api.de/api/interpreter';

The URL of the Overpass API endpoint.

=head1 SEE ALSO

  [https://wiki.openstreetmap.org/wiki/Overpass_API]

=head1 AUTHOR

Brian Duggan

=end pod



