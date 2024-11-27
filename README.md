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

This module provides a simple interface to the Overpass API.

METHODS
=======

query
-----

    method query($data) returns Str

This method sends a query to the Overpass API and returns the result.

The `$data` parameter should be a string containing the query to be executed.

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

