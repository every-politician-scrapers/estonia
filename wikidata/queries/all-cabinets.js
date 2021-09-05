module.exports = function (jurisdiction) {
  return `SELECT DISTINCT ?item ?itemLabel ?inception ?startTime ?abolished ?endTime
                  ?isa ?isaLabel ?parent ?parentLabel
                  ?replaces ?replacesLabel ?replacedBy ?replacedByLabel
                  ?follows ?followsLabel ?followedBy ?followedByLabel
  WHERE {
    ?item wdt:P31/wdt:P279* wd:Q640506 ; wdt:P1001 wd:${jurisdiction} .
    OPTIONAL { ?item wdt:P571 ?inception   }
    OPTIONAL { ?item wdt:P580 ?startTime   }
    OPTIONAL { ?item wdt:P576 ?abolished   }
    OPTIONAL { ?item wdt:P582 ?endTime     }
    OPTIONAL { ?item wdt:P31 ?isa          }
    OPTIONAL { ?item wdt:P279 ?parent      }
    OPTIONAL { ?item wdt:P1365 ?replaces   }
    OPTIONAL { ?item wdt:P1366 ?replacedBy }
    OPTIONAL { ?item wdt:P155 ?follows     }
    OPTIONAL { ?item wdt:P156 ?followedBy  }

    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
  }
  ORDER BY ?inception`
}
