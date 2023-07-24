#!/usr/bin/env bash

cd "$(dirname "$0")"

mkdir -p out
rm -f out/all-signed-nanopub-uris.txt

for PAGE in {1..50}; do
  echo "Downloading page $PAGE"
  curl -s -H "Accept: text/csv" "https://grlc.nps.petapico.org/api/local/local/find_signed_nanopubs?page=$PAGE" \
    | sed 1d \
    | awk -F, '{print $1}' \
    | sed 's/"//g' \
    >> out/all-signed-nanopub-uris.txt
done

echo "Counting downloaded nanopubs:"
cat out/all-signed-nanopub-uris.txt | wc -l

echo "Counting unique nanopubs (should be the same as above):"
cat out/all-signed-nanopub-uris.txt | sort | uniq | wc -l
