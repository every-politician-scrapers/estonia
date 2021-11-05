const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT (STRAFTER(STR(?item), STR(wd:)) AS ?wdid)
               ?name ?wdLabel ?source ?sourceDate
               (STRAFTER(STR(?positionItem), STR(wd:)) AS ?pid) ?position
               (STRAFTER(STR(?held), '/statement/') AS ?psid)
        WHERE {
          # Positions currently in the cabinet
          ?positionItem p:P361 ?ps .
          ?ps ps:P361 wd:${meta.cabinet.parent} .
          FILTER NOT EXISTS { ?ps pq:P582 [] }

          # Who currently holds those positions
          ?item wdt:P31 wd:Q5 ; p:P39 ?held .
          ?held ps:P39 ?positionItem ; pq:P580 ?start .
          FILTER NOT EXISTS { ?held wikibase:rank wikibase:DeprecatedRank }
          FILTER NOT EXISTS { ?held pq:P582 [] }

          OPTIONAL {
            ?held prov:wasDerivedFrom ?ref .
            ?ref pr:P854 ?source FILTER CONTAINS(STR(?source), '${meta.cabinet.source.url}') .

            OPTIONAL { ?ref pr:P1810 ?sourceName }
            OPTIONAL { ?ref pr:P1932 ?statedName }
            OPTIONAL { ?ref pr:P813  ?sourceDate }
          }

          OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "${meta.cabinet.source.lang.code}") }
          BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

          OPTIONAL { ?positionItem wdt:P1705  ?nativeLabel   FILTER(LANG(?nativeLabel)   = "${meta.cabinet.source.lang.code}") }
          OPTIONAL { ?positionItem rdfs:label ?positionLabel FILTER(LANG(?positionLabel) = "${meta.cabinet.source.lang.code}") }
          BIND(COALESCE(?statedName, ?nativeLabel, ?positionLabel) AS ?position)
        }
        ORDER BY STR(?name) STR(?position) ?began ?wdid ?sourceDate`
}
