#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"

mkdir -p temp
if [ ! -f temp/biolink-model.ttl ]; then
  wget -O temp/biolink-model.ttl https://raw.githubusercontent.com/biolink/biolink-model/master/biolink-model.ttl
fi

rapper -q -i turtle -o ntriples temp/biolink-model.ttl > temp/biolink-model.nt

mkdir -p out

rm -f out/biolink-related-rels.txt
rm -f out/biolink-rel-definitions.nt

echo "<https://w3id.org/biolink/vocab/related_to>" > temp/rel-todo.txt
while [ -s temp/rel-todo.txt ]; do
  E=$(head -1 temp/rel-todo.txt)
  tail -n +2 temp/rel-todo.txt > temp/rel-todo.txt.tmp
  mv temp/rel-todo.txt.tmp temp/rel-todo.txt
  if [ "$E" == "<https://w3id.org/biolink/vocab/contributor>" ]; then continue; fi
  if [[ "$E" != "<https://w3id.org/biolink/vocab/related_to_at_concept_level>"  &&
        "$E" != "<https://w3id.org/biolink/vocab/related_to_at_instance_level>" &&
        "$E" != "<https://w3id.org/biolink/vocab/same_as>" &&
        ! "$E" =~ '_match>' &&
        ! "$E" =~ 'class_of>' ]]; then
    echo "$E" >> out/biolink-related-rels.txt
  fi
  cat temp/biolink-model.nt \
    | grep " <https://w3id.org/linkml/is_a> $E ." \
    | sed -r 's/^(<[^>]+>) .*$/\1/' \
    >> temp/rel-todo.txt
done

while read E; do
  cat temp/biolink-model.nt \
    | awk -F' ' -v thing="$E" \
        '{
           if (thing == $1 && $2 == "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>") {
             type=$3;
           }
           if (thing == $1 && type == "<https://w3id.org/linkml/SlotDefinition>" && $2 == "<http://www.w3.org/2004/02/skos/core#definition>") {
             print $0;
           }
         }' \
     >> out/biolink-rel-definitions.nt
done < out/biolink-related-rels.txt

cat out/biolink-rel-definitions.nt \
  | sed -r 's|^(<https://w3id.org/biolink/vocab/([a-zA-Z0-9_\-]+)>) <http://www.w3.org/2004/02/skos/core#definition> "(.*)" .$|\1 rdfs:label "\2 - \3" .|' \
  | awk -F' ' '{ $3 = gensub(/_/, " ", "g", $3); print $0; }' \
  > out/biolink-rel-labels.nt

(
  echo "@prefix : <http://purl.org/nanopub/temp/biolink-rel-labels/> ."
  echo "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> ."
  echo "@prefix np: <http://www.nanopub.org/nschema#> ."
  echo "@prefix dct: <http://purl.org/dc/terms/> ."
  echo "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> ."
  echo "@prefix orcid: <https://orcid.org/> ."
  echo "@prefix npx: <http://purl.org/nanopub/x/> ."
  echo "@prefix prov: <http://www.w3.org/ns/prov#> ."
  echo "@prefix biolink: <https://w3id.org/biolink/vocab/> ."
  echo ""
  echo ":Head {"
  echo "  : np:hasAssertion :assertion ;"
  echo "    np:hasProvenance :provenance ;"
  echo "    np:hasPublicationInfo :pubinfo ;"
  echo "    a np:Nanopublication ."
  echo "}"
  echo ""
  echo ":assertion {"
  cat out/biolink-rel-labels.nt
  echo "}"
  echo ""
  echo ":provenance {"
  echo "  :assertion prov:wasDerivedFrom <https://raw.githubusercontent.com/biolink/biolink-model/master/biolink-model.ttl> ."
  echo "}"
  echo ""
  echo ":pubinfo {"
  echo "  : dct:creator orcid:0000-0002-1267-0234 ."
  echo "}"
) > out/biolink-rel-labels.trig

./np sign  out/biolink-rel-labels.trig

./np check out/signed.biolink-rel-labels.trig
