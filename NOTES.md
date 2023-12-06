## Make index of all signed nanopublications

    $ np mkindex -c https://orcid.org/0000-0002-1267-0234 -t 'The set of all signed nanopublications as of DATE' -s LASTINDEXURI out/all-signed-nanopub-uris.new.txt
    $ np publish index.trig && rm index.trig
    $ np get -c -o dumps/signed-nanopubs-DATE.trig.gz INDEXURI

Set new files:

    $ mv out/all-signed-nanopub-uris.latest.txt out/all-signed-nanopub-uris.txt
    $ mv out/all-signed-nanopub-uris-sorted.latest.txt out/all-signed-nanopub-uris-sorted.txt
    $ rm out/all-signed-nanopub-uris.new.txt

Snapshots:

- 24 July 2023: http://purl.org/np/RAtoc9gvPKKPu2kziwXaWHQS0FtSSOZbON9uyl9x9MsEw
- 30 August 2023: http://purl.org/np/RAwX0vH7QDwgJgTeaSNbCEIbk64rcnEg8TV66y45-gKDo
- 6 December 2023: https://w3id.org/np/RAGcCIA0LLWxFz28K0KgnIdE3hCBopeMjFjv2hGU4ol1w
- 6 December 2023 (fixed 2nd version): https://w3id.org/np/RAfF4tXMqapK7Ep-DXewCvU1Wy76uBsI-tmJmv1AqOVX0
