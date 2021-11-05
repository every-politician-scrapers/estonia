const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT ?item ?name ?surnameLabel ?riigikogu ?group ?faction ?start ?end
       (STRAFTER(STR(?statement), '/statement/') AS ?psid)
    WHERE
    {
      ?item p:P39 ?statement .
      ?statement ps:P39 ?position .
      ?position wdt:P279 wd:Q21100241 .

      OPTIONAL {
        ?statement pq:P2937 ?term .
        OPTIONAL { ?term p:P31 [ps:P31 wd:Q21115902; pq:P1545 ?riigikogu] } .
        OPTIONAL { ?term wdt:P571 ?term_start }
        OPTIONAL { ?term wdt:P576 ?term_end }
      }
      OPTIONAL { ?statement pq:P580 ?mandate_start }
      OPTIONAL { ?statement pq:P582 ?mandate_end }

      BIND(COALESCE(?mandate_start, ?term_start) AS ?start)
      BIND(COALESCE(?mandate_end, ?term_end) AS ?end)


      OPTIONAL {
        ?statement pq:P4100 ?group .
        OPTIONAL { ?group wdt:P1813 ?groupShort  FILTER(LANG(?groupShort) = 'et') }
        OPTIONAL { ?group rdfs:label ?groupLabel FILTER(LANG(?groupLabel) = "et") }
        BIND(COALESCE(?groupShort, ?groupLabel) AS ?faction)
      }
      OPTIONAL { ?item wdt:P734 ?surname }

      OPTIONAL {
        ?statement prov:wasDerivedFrom ?ref .
        ?ref pr:P854 ?source FILTER CONTAINS(STR(?source), 'riigikogu.ee')
        OPTIONAL { ?ref pr:P1810 ?sourceName }
      }
      OPTIONAL { ?item rdfs:label ?wdLabel FILTER(LANG(?wdLabel) = "et") }
      BIND(COALESCE(?sourceName, ?wdLabel) AS ?name)

      SERVICE wikibase:label { bd:serviceParam wikibase:language "et,en" }
    }
    # ${new Date().toISOString()}
    ORDER BY ?surnameLabel ?item ?riigikogu ?start`
}
