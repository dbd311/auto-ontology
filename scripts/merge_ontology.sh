#!/bin/sh
set -eo pipefail

INPUT_DIR="${1:-auto-ontology}"
OUTPUT_FILE="${2:-automobile_merged.ttl}"

# Verify input directory structure
verify_file() {
    [ -f "$1" ] || { echo "Error: Missing required file $1"; exit 1; }
}

verify_file "$INPUT_DIR/01_core/01_classes.ttl"
verify_file "$INPUT_DIR/01_core/02_object_properties.ttl"
verify_file "$INPUT_DIR/01_core/03_data_properties.ttl"

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

# Merge files with verification
merge_file() {
    local file="$1"
    verify_file "$file"
    echo "# Source: $(basename "$file")" >> "$OUTPUT_FILE"
    grep -v '^@prefix' "$file" >> "$OUTPUT_FILE"
    printf "\n\n" >> "$OUTPUT_FILE"
}

# Merge all components
for file in "$INPUT_DIR"/01_core/*.ttl \
            "$INPUT_DIR"/02_instances/*.ttl \
            "$INPUT_DIR"/03_axioms/*.ttl; do
    merge_file "$file"
done

# Validate
riot --validate "$OUTPUT_FILE" || { echo "Validation failed"; exit 1; }
echo "Ontology merged and validated successfully"