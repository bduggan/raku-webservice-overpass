use WebService::Overpass 'op', '-debug';

say op.query: q:to/OQL/;
    [out:json];
    node(1);
    out;
  OQL


say op.query: q:to/OQL/;
    [bbox:-25.38653, 130.99883, -25.31478, 131.08938];
    node;
    out skel;
OQL


say op.query: q:to/EOQ/;
   [out:csv(::id, ::lat, ::lon, name; true; ",")];
  (
    node(-25.38653, 130.99883, -25.31478, 131.08938)["natural"="cave_entrance"];
  );
  out body;
  EOQ
