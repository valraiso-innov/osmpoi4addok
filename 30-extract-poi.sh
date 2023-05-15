PBF_NAME=france_metro_dom_com_nc.osm.pbf
PBF_URL=http://download.openstreetmap.fr/extracts/merge/$PBF_NAME
#wget -N $PBF_URL

FILTER="`tail -n +2 def.csv | cut -d ',' -f 1,2 | sort | sed -E -e 's/"//g;s/([-_a-z0-9]+),([-_a-z0-9]+)/\1=\2 or/' | tr '\n' ' ' | sed -E -e 's/ and =//g' | sed -E -e 's/ or %$//'`"
osmconvert $PBF_NAME -o=latest.o5m
osmfilter latest.o5m --keep="$FILTER" -o=poi.o5m
osmconvert poi.o5m --all-to-nodes --add-bbox-tags --max-objects=1000000000 -o=nodes.o5m
osmfilter nodes.o5m --keep="$FILTER" -o=bbox.o5m
#KEY="`tail -n +2 def.csv | sed 's/"//g' | cut -d ',' -f 1 | sort -u | tr '\n' ' '`"
KEY="aerialway aerodrome aeroway amenity boundary bridge craft emergency heritage highway historic junction landuse leisure man_made military mountain_pass natural office place railway shop tourism tunnel waterway"
osmconvert bbox.o5m --csv="@id @lon @lat bBox name alt_name short_name name:fr local_name official_name old_name $KEY" --csv-headline > poi.csv
#rm *.o5m
