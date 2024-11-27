[![Actions Status](https://github.com/bduggan/raku-webservice-overpass/actions/workflows/linux.yml/badge.svg)](https://github.com/bduggan/raku-webservice-overpass/actions/workflows/linux.yml)
[![Actions Status](https://github.com/bduggan/raku-webservice-overpass/actions/workflows/macos.yml/badge.svg)](https://github.com/bduggan/raku-webservice-overpass/actions/workflows/macos.yml)

NAME
====

WebService::Overpass - A simple interface to the Overpass API

SYNOPSIS
========

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

DESCRIPTION
===========

This is a simple interface to the Overpass API. Overpass is an API for retrieving OpenStreetMap data. Queries use the Overpass Query Language (Overpass QL).

METHODS
=======

query
-----

    method query($data) returns Str

Send a query and return the result (as a string).

The `$data` parameter should be a complete overpass query.

The format of the response depends on the first line of the query (csv, json etc). No parsing is currently done by this module.

ATTRIBUTES
==========

url
---

    has $.url = 'https://overpass-api.de/api/interpreter';

The URL of the Overpass API endpoint.

SEE ALSO
========

https://wiki.openstreetmap.org/wiki/Overpass_API

AUTHOR
======

Brian Duggan

