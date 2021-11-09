#!/bin/sh

TMPFILE=$(mktemp)
HOLDERS=$(mktemp)
RAWBIOS=$(mktemp)
BIO_CSV=$(mktemp)

PERSON_PROPS="en,P31,P18,P21,P27,P1559,P1477,P2561,P735,P734,P1950,P5056,P2652,P569,P19,P570,P22,P25,P26,P40,P3373,P39,P69,P511,P102,P3602"

# Current holders of each wanted position
qsv select position wikidata/wanted-positions.csv |
  qsv behead |
  xargs wd sparql pcb/holders.js -f csv > $TMPFILE
sed -e 's#http://www.wikidata.org/entity/##g' -e 's/T00:00:00Z//g' $TMPFILE > $HOLDERS

# Biographical info for current officeholders
qsv select person $HOLDERS |
  qsv dedup |
  qsv sort |
  qsv behead |
  wd data --props $PERSON_PROPS --simplify --time-converter simple-day --keep qualifiers,nontruthy,ranks,nondeprecated > $RAWBIOS

# TODO: prioritise 'preferred'
echo "id,name,gender,dob,dod,image" > $BIO_CSV
jq -r '[.id, .labels.en, .claims.P21[0].value, .claims.P569[0].value, .claims.P570[0].value, .claims.P18[0].value] | @csv' $RAWBIOS |
  sed -e 's/Q6581097/male/' -e 's/Q6581072/female/' >> $BIO_CSV

# Generate current.csv
qsv join position wikidata/wanted-positions.csv position $HOLDERS |
  qsv select position,title,person,start > $TMPFILE
qsv join person $TMPFILE id $BIO_CSV |
  qsv select title,name,person,start,gender,dob,dod,image |
  qsv rename position,person,personID,start,gender,DOB,DOD,image > html/current.csv

# Generate HTML
erb country="$(jq -r .jurisdiction.name meta.json)" csvfile=html/current.csv -r csv -T- pcb/index.erb > html/index.html

echo "No matches for:"
qsv join --left-anti title wikidata/wanted-positions.csv position html/current.csv
