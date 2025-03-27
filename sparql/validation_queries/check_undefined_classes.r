PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?class WHERE {
  ?class a owl:Class .
  FILTER NOT EXISTS { ?class rdfs:label ?label }
  FILTER(STRSTARTS(STR(?class), "http://automobile.org/auto#"))
}