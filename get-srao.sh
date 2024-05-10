#!/usr/bin/env bash

set -e

USAGE="$ ./get-srao.sh"

if [ ! -z $1 ]; then
  echo "Usage: $USAGE"; exit 1
fi

cd "$(dirname "$0")"

mkdir -p out

wget -O temp/srao.owl https://raw.githubusercontent.com/FAIRsharing/subject-ontology/master/SRAO.owl

rapper -i rdfxml -o ntriples temp/srao.owl \
  | grep ' <http://www.w3.org/2000/01/rdf-schema#subClassOf> .* .$' \
  > out/srao-hierarchy.ttl

echo "Processing $(cat out/srao-hierarchy.ttl | wc -l) hierarchy triples..."

(
  echo "@prefix : <http://purl.org/nanopub/temp/srao-hierarchy/> ."
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
  cat out/srao-hierarchy.ttl
  echo "}"
  echo ""
  echo ":provenance {"
  echo "  :assertion prov:wasDerivedFrom <https://raw.githubusercontent.com/FAIRsharing/subject-ontology/master/SRAO.owl> ."
  echo "}"
  echo ""
  echo ":pubinfo {"
  echo "  : dct:creator orcid:0000-0002-1267-0234 ."
  echo "  : npx:hasNanopubType <https://w3id.org/fair/fip/terms/FAIR-Implementation-Community> ."
  echo "}"
) >> out/srao-hierarchy.trig

./np sign out/srao-hierarchy.trig

./np check out/signed.srao-hierarchy.trig
