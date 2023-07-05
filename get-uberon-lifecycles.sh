#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

mkdir -p out

curl 'https://www.ebi.ac.uk/ols/api/select?ontology=uberon&fieldList=iri,label,description&rows=60&wt=xml&childrenOf=http://purl.obolibrary.org/obo/UBERON_0000105&q=?' \
  | python -m json.tool \
  | grep --no-group-separator -A 1 '"iri": "http://purl.obolibrary.org/obo/UBERON_' \
  | perl -p -e 's/(UBERON_[0-9]+",)\n/$1/' \
  | sed -r 's/^.*"iri": "(.+)",.*"label": (".*")$/  <\1> rdfs:label \2 ./' \
  > out/uberon-lifecycle-labels.ttl

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
  cat out/uberon-lifecycle-labels.ttl
  echo "}"
  echo ""
  echo ":provenance {"
  echo "  :assertion prov:wasDerivedFrom <https://www.ebi.ac.uk/ols/api> ."
  echo "}"
  echo ""
  echo ":pubinfo {"
  echo "  : dct:creator orcid:0000-0002-1267-0234 ."
  echo "}"
) > out/uberon-lifecycle-labels.trig

./np sign out/uberon-lifecycle-labels.trig

./np check out/signed.uberon-lifecycle-labels.trig
