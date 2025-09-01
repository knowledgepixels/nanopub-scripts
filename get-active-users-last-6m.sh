#!/usr/bin/env bash

set -e

USAGE="$ ./get-active-users-last-6m.sh"

if [ ! -z $1 ]; then
  echo "Usage: $USAGE"; exit 1
fi

curl -s -H 'accept: text/csv' \
    'https://query.knowledgepixels.com/api/RAYtPECxCxpoEIAQuB0WJtDMw7TQjZFLt938It2oo6IgQ/get-active-users-last-6m' \
  | sed 's/\r//' \
  > out/active-users-last-6m.csv

cat out/active-users-last-6m.csv \
  | wc -l
