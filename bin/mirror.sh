#!/bin/bash

CURLOPTS='-L -c /tmp/cookies -A eps/1.2'

curl $CURLOPTS -o sources/cabinet-official/official.html $(jq -r .source.url sources/cabinet-official/meta.json)
curl $CURLOPTS -o sources/riigikogu-official/official.html $(jq -r .source.url sources/riigikogu-official/meta.json)
