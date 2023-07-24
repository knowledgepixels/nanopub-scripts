## Make index of all signed nanopublications

    $ np mkindex -c https://orcid.org/0000-0002-1267-0234 -t 'The set of all signed nanopublications as of 24 July 2023' load/all-signed-nanopub-uris.txt
    $ np publish index.trig
    $ np get -c -o dumps/signed-nanopubs-20230724.trig.gz http://purl.org/np/RAtoc9gvPKKPu2kziwXaWHQS0FtSSOZbON9uyl9x9MsEw
