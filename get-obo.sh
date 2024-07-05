#!/usr/bin/env bash

set -e

USAGE="$ ./get-obo.sh NCIT_C40098"

if [ -z $1 ] || [ ! -z $2 ]; then
  echo "Usage: $USAGE"; exit 1
fi

cd "$(dirname "$0")"

mkdir -p out

curl -L "https://ontobee.org/ontology/catalog/NCIT?iri=http://purl.obolibrary.org/obo/$1" \
  | grep -A 1 '<a class="term"' \
  | tr -d '\n' \
  | sed -r 's|</li>(</ul>)?|</li>\n|g' \
  | sed -r 's|^.*/NCIT\?iri=(.*)">(.*)</a>.*$|<\1> <http://www.w3.org/2000/01/rdf-schema#label> "\2" .|' \
  > out/obo-$1.ttl

cat out/obo-$1.ttl

(
  echo "@prefix : <http://purl.org/nanopub/temp/obo-labels/> ."
  echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
  echo "@prefix np: <http://www.nanopub.org/nschema#> ."
  echo "@prefix dct: <http://purl.org/dc/terms/> ."
  echo "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> ."
  echo "@prefix orcid: <https://orcid.org/> ."
  echo "@prefix npx: <http://purl.org/nanopub/x/> ."
  echo "@prefix prov: <http://www.w3.org/ns/prov#> ."
  echo "@prefix obo: <http://purl.obolibrary.org/obo/> ."
  echo ""
  echo ":Head {"
  echo "  : np:hasAssertion :assertion ;"
  echo "    np:hasProvenance :provenance ;"
  echo "    np:hasPublicationInfo :pubinfo ;"
  echo "    a np:Nanopublication ."
  echo "}"
  echo ""
  echo ":assertion {"
  cat out/obo-$1.ttl
  echo "}"
  echo ""
  echo ":provenance {"
  echo "  :assertion prov:wasDerivedFrom <https://ontobee.org/ontology/catalog/NCIT> ."
  echo "}"
  echo ""
  echo ":pubinfo {"
  echo '  : rdfs:label "Labels for OBO classes under '"$1"'" .'
  echo "  : npx:hasNanopubType rdfs:label ."
  echo "  : dct:creator orcid:0000-0002-1267-0234 ."
  echo '  : dct:created "'$(./np now)'"^^xsd:dateTime .'
  echo "}"
) > out/obo-$1-labels.trig

./np sign out/obo-$1-labels.trig

./np check out/signed.obo-$1-labels.trig
