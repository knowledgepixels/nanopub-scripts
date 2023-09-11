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

(
  echo "@prefix : <http://purl.org/nanopub/temp/uberon-lifecycles-labels/> ."
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
  cat out/$1-labels.ttl
  echo "}"
  echo ""
  echo ":provenance {"
  echo "  :assertion prov:wasDerivedFrom <https://vocab.nerc.ac.uk/collection/S04/current/> ."
  echo "}"
  echo ""
  echo ":pubinfo {"
  echo "  : dct:creator orcid:0000-0002-1267-0234 ."
  echo "}"
) > out/$1-labels.trig

./np sign out/$1-labels.trig

./np check out/signed.$1-labels.trig
