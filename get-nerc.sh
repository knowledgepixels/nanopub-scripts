#!/usr/bin/env bash

set -e

USAGE="$ ./get-nerc.sh S04"

if [ -z $1 ] || [ ! -z $2 ]; then
  echo "Usage: $USAGE"; exit 1
fi

cd "$(dirname "$0")"

mkdir -p out

wget -O temp/$1.ttl "https://vocab.nerc.ac.uk/collection/$1/current/?_profile=nvs&_mediatype=text/turtle"
rapper -i turtle -o ntriples temp/$1.ttl \
  | grep ' <http://www.w3.org/2004/02/skos/core#prefLabel> .*@en .$' \
  | sed -r 's|(<.*>) <http://www.w3.org/2004/02/skos/core#prefLabel> (.*)$|  \1 rdfs:label \2|' \
  > out/$1-labels.ttl

echo "Processing $(cat out/$1-labels.ttl | wc -l) labels..."

cp out/$1-labels.ttl temp/$1-labels-rest.ttl
rm -f out/$1-labels.trig
count=0

while [[ -f "temp/$1-labels-rest.ttl" ]]; do

  ((count=count+1))
  if [[ $(cat temp/$1-labels-rest.ttl | wc -l) -gt 1000 ]]; then
    echo "Packaging next 1000 labels..."
    head -1000 temp/$1-labels-rest.ttl > temp/$1-labels-next.ttl
    tail +1001 temp/$1-labels-rest.ttl > temp/$1-labels-rest.ttl.new
    mv temp/$1-labels-rest.ttl.new temp/$1-labels-rest.ttl
  else
    echo "Processing last $(cat temp/$1-labels-rest.ttl | wc -l) labels..."
    mv temp/$1-labels-rest.ttl temp/$1-labels-next.ttl
  fi

  (
    echo "@prefix : <http://purl.org/nanopub/temp/uberon-lifecycles-labels/$count> ."
    echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
    echo "@prefix np: <http://www.nanopub.org/nschema#> ."
    echo "@prefix dct: <http://purl.org/dc/terms/> ."
    echo "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> ."
    echo "@prefix orcid: <https://orcid.org/> ."
    echo "@prefix npx: <http://purl.org/nanopub/x/> ."
    echo "@prefix prov: <http://www.w3.org/ns/prov#> ."
    echo ""
    echo ":Head {"
    echo "  : np:hasAssertion :assertion ;"
    echo "    np:hasProvenance :provenance ;"
    echo "    np:hasPublicationInfo :pubinfo ;"
    echo "    a np:Nanopublication ."
    echo "}"
    echo ""
    echo ":assertion {"
    cat temp/$1-labels-next.ttl
    echo "}"
    echo ""
    echo ":provenance {"
    echo "  :assertion prov:wasDerivedFrom <https://vocab.nerc.ac.uk/collection/S04/current/> ."
    echo "}"
    echo ""
    echo ":pubinfo {"
    echo "  : dct:creator orcid:0000-0002-1267-0234 ."
    echo "}"
  ) >> out/$1-labels.trig

done

./np sign out/$1-labels.trig

./np check out/signed.$1-labels.trig
