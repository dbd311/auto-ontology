#!/bin/bash
set -e

ONTOLOGY_FILE=$1
QUERY_DIR=$2
OUTPUT_DIR=sparql_results

mkdir -p $OUTPUT_DIR

for query in $QUERY_DIR/*.rq; do
    query_name=$(basename $query .rq)
    sparql --data $ONTOLOGY_FILE --query $query > $OUTPUT_DIR/${query_name}.json
done