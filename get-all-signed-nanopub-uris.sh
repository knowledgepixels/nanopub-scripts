#!/usr/bin/env bash

cd "$(dirname "$0")"

mkdir -p out
rm -f out/all-signed-nanopub-uris.latest.txt

for PAGE in {1..50}; do
  echo "Downloading page $PAGE"
  curl -s -H "Accept: text/csv" "https://grlc.nps.petapico.org/api/local/local/find_signed_nanopubs?page=$PAGE" \
    | sed 1d \
    | awk -F, '{print $1}' \
    | sed 's/"//g' \
    >> out/all-signed-nanopub-uris.latest.txt
done

echo "Counting downloaded nanopubs:"
cat out/all-signed-nanopub-uris.latest.txt | wc -l

cat out/all-signed-nanopub-uris.latest.txt | sort | uniq > out/all-signed-nanopub-uris-sorted.latest.txt

echo "Counting unique nanopubs (should be the same as above):"
cat out/all-signed-nanopub-uris-sorted.latest.txt | wc -l

comm -13 out/all-signed-nanopub-uris-sorted.txt out/all-signed-nanopub-uris-sorted.latest.txt > out/all-signed-nanopub-uris.new.txt

echo "New nanopubs since last run:"
cat out/all-signed-nanopub-uris.new.txt | wc -l
