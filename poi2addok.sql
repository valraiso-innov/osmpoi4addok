CREATE TEMP TABLE poi_tag AS
SELECT
  id::numeric,
  lat,
  lon,
  coalesce('aerialway='||aerialway, 'aerodrome='||aerodrome, 'aeroway='||aeroway, 'amenity='||amenity, 'boundary='||boundary, 'bridge='||bridge, 'craft='||craft, 'emergency='||emergency, 'heritage='||heritage, 'highway='||highway, 'historic='||historic, 'junction='||junction, 'landuse='||landuse, 'leisure='||leisure, 'man_made='||man_made, 'military='||military, 'mountain_pass='||mountain_pass, 'natural='||"natural", 'office='||office, 'place='||place, 'railway='||railway, 'shop='||shop, 'tourism='||tourism, 'tunnel='||tunnel, 'waterway='||waterway) AS tag,
  name,
  insee AS citycode,
  c.nom AS city
FROM
  poi
  JOIN com AS c ON
    ST_Intersects(poi.geom, c.geom)
;

CREATE INDEX idx_def_tag ON def((key1 || '=' || value1));


\pset tuples_only
\a
\o poi.json
SELECT
  row_to_json(t)
FROM (
  SELECT
    format('http://osm.org/%s/%s',case when id<1000000000000000 then 'node' when id>2000000000000000 then 'relation' else 'way' end, id % 1000000000000000) as id,
    'poi' AS type,
    value1 AS poi,
    (SELECT array_agg(case
      when lower(unaccent(name)) like '%'||lower(unaccent(trim(v)))||'%' then name
      when name is null then trim(v)
      else trim(format('%s (%s)',coalesce(name,''),trim(v))) end)
      FROM unnest(regexp_split_to_array(label, ' / ')) AS t(v)) AS name,
    lat,
    lon,
    city,
    citycode,
    rank::numeric AS importance
  FROM
    poi_tag
    JOIN def ON
      tag = key1 || '=' || value1
  WHERE
    rank IS NOT NULL AND
    rank != '0'
) AS t
;
\o
