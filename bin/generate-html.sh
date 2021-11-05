#!/bin/sh

TMPFILE=$(mktemp)
HOLDERS=$(mktemp)
SORTED_BIOS=$(mktemp)
UNIQUE_BIOS=$(mktemp)

# Current holders of each wanted position
xsv select position pc/wanted-positions.csv |
  tail +2 |
  xargs wd sparql bin/holders.js -f csv > $TMPFILE
sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' $TMPFILE > $HOLDERS

# Biographical info for current officeholders
xsv select person $HOLDERS |
  xsv sort |
  uniq  |
  tail +2 |
  xargs wd sparql bin/bios.js -f csv > $TMPFILE
sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' $TMPFILE |
  sort -t, -k1,1 -r > $SORTED_BIOS

# Remove (and report on) extraneous bio info
sort -t, -k1,1 -r -u $SORTED_BIOS > $UNIQUE_BIOS
diff -C 0 $UNIQUE_BIOS $SORTED_BIOS  | grep  '^+'

# Generate current.csv
xsv join position pc/wanted-positions.csv position $HOLDERS |
  xsv select tab,position,title,slug,person,start > $TMPFILE
xsv join person $TMPFILE person $UNIQUE_BIOS |
  xsv select tab,title,start,person,personLabel,genderLabel,dob,dobPrecision,dod,dodPrecision,image |
  ifne tee pc/current.csv

# Generate HTML
erb country=$(jq -r .jurisdiction.name meta.json) csvfile=pc/current.csv -r csv -T- template/index.erb |
  ifne tee pc/index.html
