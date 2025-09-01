#!/usr/bin/env bash

set -e

USAGE="$ ./get-user-countries.sh"

if [ ! -z $1 ]; then
  echo "Usage: $USAGE"; exit 1
fi

rm -f temp/user-country-log.txt

cat out/active-users-last-6m.csv \
  | awk '{ print "./get-user-country.sh "$1" >> temp/user-country-log.txt ; echo "$1; }' \
  | bash

cat temp/user-country-log.txt \
  | sort \
  | uniq -c \
  | sort -nr \
  > out/user-countries.txt