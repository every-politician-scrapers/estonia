const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  return `SELECT DISTINCT ?id ?name (STRAFTER(STR(?statement), '/statement/') AS ?psid)
    WHERE {
      # Current members of the Riigikogu
      ?item p:P39 ?ps .
      ?ps ps:P39 wd:${meta.legislature.term.id} .
      FILTER NOT EXISTS { ?ps pq:P582 [] }

      # A Riigikogu ID, and optional "named as"
      OPTIONAL {
        ?item p:P4287 ?idstatement .
        ?idstatement ps:P4287 ?id .
        OPTIONAL { ?idstatement pq:P1810 ?riigikoguName }
      }

      # Their on-wiki label as a fall-back if no Riigikogu name
      OPTIONAL { ?item rdfs:label ?etLabel FILTER(LANG(?etLabel) = "et") }
      BIND(COALESCE(?riigikoguName, ?etLabel) AS ?name)
    }
    # ${new Date().toISOString()}
    ORDER BY ?name`
}
