#!/usr/bin/env bash

set -e

USAGE="$ ./get-bioportal.sh ISO639-1"

if [ -z $1 ] || [ ! -z $2 ]; then
  echo "Usage: $USAGE"; exit 1
fi

cd "$(dirname "$0")"

mkdir -p out

wget -O temp/$1.xrdf "https://data.bioontology.org/ontologies/$1/download?apikey=8b5b7825-538d-40e0-9e9e-5ab9274a9aeb&download_format=rdf"
rapper -i rdfxml -o ntriples temp/$1.xrdf \
  | grep ' <http://www.w3.org/2004/02/skos/core#definition> .*@en .$' \
  | sed -r 's|(<.*>) <http://www.w3.org/2004/02/skos/core#definition> (.*)$|  \1 rdfs:label \2|' \
  > out/bioportal-$1-labels.ttl

(
  echo "@prefix : <http://purl.org/nanopub/temp/bioportal-labels/> ."
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
  cat out/bioportal-$1-labels.ttl
  echo "}"
  echo ""
  echo ":provenance {"
  echo "  :assertion prov:wasDerivedFrom <https://ontobee.org/ontology/catalog/NCIT> ."
  echo "}"
  echo ""
  echo ":pubinfo {"
  echo '  : rdfs:label "Labels for BioPortal classes under '"$1"'" .'
  echo "  : npx:hasNanopubType rdfs:label ."
  echo "  : dct:creator orcid:0000-0002-1267-0234 ."
  echo '  : dct:created "'$(./np now)'"^^xsd:dateTime .'
  echo "}"
) > out/bioportal-$1-labels.trig

./np sign out/bioportal-$1-labels.trig

./np check out/signed.bioportal-$1-labels.trig
