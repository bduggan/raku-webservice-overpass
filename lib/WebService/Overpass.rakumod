class WebService::Overpass {

use HTTP::Tiny;
use JSON::Fast;
use XML;
use Log::Async;

logger.untapped-ok = True;

has $.url = 'https://overpass-api.de/api/interpreter';
has $.ua = HTTP::Tiny.new;
has $.logger = logger;
has Str @.statements is rw;
has %.settings is rw;

method execute(Bool :$xml, Bool :$json, Bool :$raw) {
  my %settings := self.settings;
  warning "no output format given" unless $json || $xml || self.settings<out>;
  %settings<out> = 'json' if $json;
  %settings<out> = 'xml' if $xml;
  my $stmt = self.statements.join("\n");
  # format: [out:json] [timeout:30] [bbox:$bbox] ;
  my $str = %settings.map({ '[' ~ .key ~ ':' ~ .value ~ ']' }).join(' ');
  my $use-json = $json || (%settings<out>  // '' ) eq 'json';
  my $use-xml = $xml || (%settings<out> // '' ) eq 'xml';
  my $data = $str ~ ';' ~ "\n" ~ $stmt;
  if $raw {
    return self.query: $data;
  }
  self.query: $data, :json($use-json), :xml($use-xml);
}

method query(Str $data, Bool :$json, Bool :$xml) {
  debug "Running overpass query";
  debug "> $_" for $data.lines;
  my $res = HTTP::Tiny.new.post: $!url, :content(%(:$data));
  unless $res<success> {
    note $res<content>.decode;
    die "Error querying Overpass API: $res<status> $res<reason>";
  }
  my $out = $res<content>.decode;
  return from-json($out) if $json;
  return from-xml($out) if $xml;
  $out;
}

=begin pod

=head1 NAME

WebService::Overpass - A simple interface to the Overpass API

=head1 SYNOPSIS

Get a node from OpenStreetMap:

  use WebService::Overpass 'op';

  op.logger.send-to: $*ERR;

  say op.query: q:to/OQL/;
      [out:json];
      node(1);
      out;
    OQL

Output:

  2024-11-28T08:38:08.234432-05:00 (1) debug: Running overpass query
  2024-11-28T08:38:08.238386-05:00 (1) debug: > [out:json];
  2024-11-28T08:38:08.238688-05:00 (1) debug: > node(1);
  2024-11-28T08:38:08.239029-05:00 (1) debug: > out;

  {
    "version": 0.6,
    "generator": "Overpass API 0.7.62.4 2390de5a",
    "elements": [
        {
          "type": "node",
          "id": 1,
          "lat": 42.7957187,
          "lon": 13.5690032,
          ...
        }
    ],
    ...
  }

Get XML of nodes in a bounding box:

  say op.query: q:to/OQL/;
    [bbox:-25.38653, 130.99883, -25.31478, 131.08938];
    node;
    out skel;
  OQL

Output:

  <?xml version="1.0" encoding="UTF-8"?>
  <osm version="0.6" generator="Overpass API 0.7.62.4 2390de5a">
  <note>The data included in this document is from www.openstreetmap.org. The data is made available under ODbL.</note>
  <meta osm_base="2024-11-28T13:47:15Z"/>
  ...

    <bounds minlat="-25.3865300" minlon="130.9988300" maxlat="-25.3147800" maxlon="131.0893800"/>

    <node id="29342040" lat="-25.3572166" lon="131.0427522"/>
    <node id="29342041" lat="-25.3570627" lon="131.0413463"/>
  ...

Get a CSV with nodes tagged as cave entrance:

  say op.query: q:to/OQL/;
     [out:csv(::id, ::lat, ::lon, name; true; ",")];
    (
      node(-25.38653, 130.99883, -25.31478, 131.08938)["natural"="cave_entrance"];
    );
    out body;
  OQL

Output:

  @id,@lat,@lon,name
  2377985489,-25.3431812,131.0229585,Itjaritjatiku Yuu
  2377985491,-25.3409557,131.0252996,Kulpi Minymaku
  2377985515,-25.3427478,131.0246858,Kulpi Watiku
  ...

Construct queries with the C<statements> attribute:

  my \op = WebService::Overpass.new;
  op.statements = <node(1); out meta;>;

  # same thing:
  say op.execute(:xml).elements[2].attribs<lat lon>.map(+*).List.raku;
  say op.execute(:json)<elements>[0]<lat lon>.raku;

See the L<tutorial|https://osm-queries.ldodds.com/tutorial/index.html> for more examples.

=head1 DESCRIPTION

This is a simple interface to the Overpass API.  Overpass is an API
for retrieving OpenStreetMap data.  Queries use the Overpass Query
Language (Overpass QL).

=head1 EXPORTS

If an argument is given to the module, it is assumed to be a name
and the module creates a new object of type C<WebService::Overpass>
and exports it.

=head1 METHODS

=head2 query

  method query($data, Bool :$json, Bool :$xml) returns Str

Send a complete query and return the result (as a string).

The C<$data> parameter should be a complete overpass query.  Overpass
queries consist of "settings" followed by a semicolon, and then "statements".
The settings are key-value pairs in square brackets.

The format of the response depends on the first line of the query (csv,
json etc).  If C<:json> is True, the response is parsed as JSON.  If
C<:xml> is True, the response is parsed as XML.  Otherwise, it
is returned as a string.  For "smarter" behavior, use the C<execute>
method below.

=head2 execute

  method execute(:$xml, :$json, :$raw) returns Any

Send a query and return the result as a raku data structure.

The C<statements> and C<settings> attributes are used to construct the
query.  The C<statements> attribute is an array of strings, each of
which is a line in the query.  The C<settings> attribute is a hash of
settings that are prepended to the query.

The C<:xml> and C<:json> parameters are optional and specify the
output format.  They also add an "out" setting to the query.  Note
that CSVs need to be done manually, because the fields are part of
the settings.  For instance

  op.settings<out> = 'csv(::id, ::lat, ::lon, name; true; ",")';

The "true" indicates that a header row should be included.  The
comma is the separator.

The C<:raw> parameter is optional and specifies that the raw response
should be returned as a string.  Sending C<:json> and C<:raw> for
instance will set the format to json in the payload, but then return
the raw unparsed JSON in the response.

=head1 ATTRIBUTES

=head2 url

  has $.url = 'https://overpass-api.de/api/interpreter';

The URL of the Overpass API endpoint.

=head2 settings

  has %.settings is rw;

A hash of settings that are prepended to the query.  The keys are the
setting names and the values are the setting values.

=head2 statements

  has Str @.statements is rw;

An array of strings, each of which is a line in the query.  Every statement
should end with a semicolon.

=head1 EXAMPLES

Run the same query in different formats:

  use WebService::Overpass;

  my \op = WebService::Overpass.new;

  op.statements = <node(1); out meta;>;

  say op.execute(:xml).elements[2].attribs<lat lon>;

  say op.execute(:json)<elements>[0]<lat lon>;

  op.settings<out> = 'csv(::id, ::lat, ::lon, name; true; ",")';
  say op.execute;

=head1 SEE ALSO

https://wiki.openstreetmap.org/wiki/Overpass_API

=head1 AUTHOR

Brian Duggan

=end pod

}

sub EXPORT($name = Nil, *@args) {
  return %( ) without $name;
  my $obj = WebService::Overpass.new;
  $obj.logger.send-to: $*ERR if @args.first: * eq '-debug';
  %( $name => $obj );
}

