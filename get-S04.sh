#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

mkdir -p out

wget -O temp/S04.ttl 'https://vocab.nerc.ac.uk/collection/S04/current/?_profile=nvs&_mediatype=text/turtle'
rapper -i turtle -o ntriples temp/S04.ttl \
  | grep ' <http://www.w3.org/2004/02/skos/core#prefLabel> .*@en .$' \
  | sed -r 's|(<.*>) <http://www.w3.org/2004/02/skos/core#prefLabel> (.*)$|  \1 rdfs:label \2|' \
  > out/S04-labels.ttl

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
  cat out/S04-labels.ttl
  echo "}"
  echo ""
  echo ":provenance {"
  echo "  :assertion prov:wasDerivedFrom <https://vocab.nerc.ac.uk/collection/S04/current/> ."
  echo "}"
  echo ""
  echo ":pubinfo {"
  echo "  : dct:creator orcid:0000-0002-1267-0234 ."
  echo "}"
) > out/S04-labels.trig

./np sign out/S04-labels.trig

./np check out/signed.S04-labels.trig
