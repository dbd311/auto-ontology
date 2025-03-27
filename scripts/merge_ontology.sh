#!/bin/bash
set -eo pipefail

INPUT_DIR="${1:-auto-ontology}"
OUTPUT_FILE="${2:-automobile_merged.ttl}"

# Create header
cat > "$OUTPUT_FILE" << 'HEADER'
@prefix : <http://automobile.org/auto#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix swrl: <http://www.w3.org/2003/11/swrl#> .
@prefix swrlb: <http://www.w3.org/2003/11/swrlb#> .

<http://automobile.org/auto>
    a owl:Ontology ;
    rdfs:label "Automobile Ontology" .

HEADER

# Merge function
merge_files() {
    for file in "$@"; do
        if [ ! -f "$file" ]; then
            echo "Error: Missing required file $file" >&2
            exit 1
        fi
        echo "# Source: $file" >> "$OUTPUT_FILE"
        grep -v '^@prefix' "$file" | dos2unix >> "$OUTPUT_FILE"
        echo -e "\n" >> "$OUTPUT_FILE"
    done
}

# Merge all components
merge_files "$INPUT_DIR"/01_core/*.ttl
merge_files "$INPUT_DIR"/02_instances/*.ttl
merge_files "$INPUT_DIR"/03_axioms/*.ttl

# Validate
riot --validate "$OUTPUT_FILE"