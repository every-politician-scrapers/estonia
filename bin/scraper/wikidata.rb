#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

query = <<SPARQL
  SELECT (STRAFTER(STR(?item), STR(wd:)) AS ?wdid) ?name (STRAFTER(STR(?positionItem), STR(wd:)) AS ?pid) ?position
  WHERE {
    BIND (wd:Q105071498 AS ?cabinet) .

    # Dates of this cabinet
    ?cabinet wdt:P31 ?parent .

    # Positions currently in the cabinet
    ?positionItem p:P361 ?ps .
    ?ps ps:P361 ?parent .
    FILTER NOT EXISTS { ?ps pq:P582 [] }

    # Who currently holds those positions
    ?item p:P39 ?held .
    ?held ps:P39 ?positionItem ; pq:P580 ?start .
    FILTER NOT EXISTS { ?held pq:P582 [] }

    OPTIONAL { ?item rdfs:label ?name FILTER(LANG(?name) = "et") }

    OPTIONAL { ?positionItem wdt:P1705 ?nativeLabel }
    OPTIONAL { ?positionItem rdfs:label ?positionLabel FILTER(LANG(?positionLabel) = "et") }
    BIND(COALESCE(?nativeLabel, ?positionLabel) AS ?position)
  }
  ORDER BY ?positionLabel ?began
SPARQL

agent = 'every-politican-scrapers/estonia-cabinet'
puts EveryPoliticianScraper::WikidataQuery.new(query, agent).csv
