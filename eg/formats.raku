use WebService::Overpass;

my \op = WebService::Overpass.new;
op.logger.send-to: $*ERR;

op.statements = <node(1); out meta;>;

say op.execute(:xml).elements[2].attribs<lat lon>.map(+*).List.raku;

say op.execute(:json)<elements>[0]<lat lon>.raku;

