use WebService::Overpass;

my \op = WebService::Overpass.new;
op.logger.send-to: $*ERR;

op.statements = <node(1); out meta;>;

say op.execute(:xml).elements[2].attribs<lat lon>;

say op.execute(:json)<elements>[0]<lat lon>;

op.settings<out> = 'csv(::id, ::lat, ::lon, name; true; ",")';
say op.execute;

