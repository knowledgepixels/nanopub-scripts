#!/usr/bin/env bash

set -e

USAGE="$ ./get-user-country.sh https://orcid.org/0000-0002-1267-0234"

if [ -z $1 ] || [ ! -z $2 ]; then
  echo "Usage: $USAGE"; exit 1
fi

curl -s -L -H "Accept: application/json" $1 \
  | python -c "import sys, json; print(json.load(sys.stdin)['activities-summary']['employments']['affiliation-group'][0]['summaries'][0]['employment-summary']['organization']['address']['country'])"
