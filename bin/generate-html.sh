#!/bin/sh

TMPFILE=$(mktemp)
HOLDERS=$(mktemp)
SORTED_BIOS=$(mktemp)
UNIQUE_BIOS=$(mktemp)

# Current holders of each wanted position
qsv select position pc/wanted-positions.csv |
  qsv behead |
  xargs wd sparql bin/holders.js -f csv > $TMPFILE
sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' $TMPFILE > $HOLDERS

# Biographical info for current officeholders
qsv select person $HOLDERS |
  qsv dedup |
  qsv behead |
  xargs wd sparql bin/bios.js -f csv > $TMPFILE
sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' $TMPFILE > $SORTED_BIOS

# Remove (and report on) extraneous bio info
qsv dedup -s person -D wikidata/results/extraneous-bios.csv $SORTED_BIOS > $UNIQUE_BIOS

# Generate current.csv
qsv join position pc/wanted-positions.csv position $HOLDERS |
  qsv select position,title,person,start > $TMPFILE
qsv join person $TMPFILE person $UNIQUE_BIOS |
  qsv select title,start,person,personLabel,genderLabel,dob,dobPrecision,dod,dodPrecision,image |
  ifne tee pc/current.csv

# Generate HTML
erb country=$(jq -r .jurisdiction.name meta.json) csvfile=pc/current.csv -r csv -T- template/index.erb |
  ifne tee pc/index.html
