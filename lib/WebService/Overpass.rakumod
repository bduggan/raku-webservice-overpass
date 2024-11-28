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

Get a node from OpenStreetMap:

  use WebService::Overpass;

  my \op = WebService::Overpass.new;
  op.logger.send-to: $*ERR; # optional

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

See the L<tutorial|https://osm-queries.ldodds.com/tutorial/index.html> for more examples.

=head1 DESCRIPTION

This is a simple interface to the Overpass API.  Overpass is an API
for retrieving OpenStreetMap data.  Queries use the Overpass Query
Language (Overpass QL).

=head1 METHODS

=head2 query

  method query($data) returns Str

Send a query and return the result (as a string).

The C<$data> parameter should be a complete overpass query.

The format of the response depends on the first line of the query (csv,
json etc).  No parsing is currently done by this module.

=head1 ATTRIBUTES

=head2 url

  has $.url = 'https://overpass-api.de/api/interpreter';

The URL of the Overpass API endpoint.

=head1 SEE ALSO

https://wiki.openstreetmap.org/wiki/Overpass_API

=head1 AUTHOR

Brian Duggan

=end pod
