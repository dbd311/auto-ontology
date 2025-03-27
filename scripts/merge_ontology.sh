#!/bin/bash
set -eo pipefail

INPUT_DIR="${1:-.}"  # Default to current directory
OUTPUT_FILE="${2:-automobile_merged.ttl}"

# Verify input files
required_files=(
  "$INPUT_DIR/01_core/01_classes.ttl"
  "$INPUT_DIR/01_core/02_object_properties.ttl"
  "$INPUT_DIR/02_instances/02_engines.ttl"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Error: Missing required file $file" >&2
    exit 1
  fi
done

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

# Merge all files
for dir in 01_core 02_instances 03_axioms; do
  for file in "$INPUT_DIR"/"$dir"/*.ttl; do
    echo "# Source: $file" >> "$OUTPUT_FILE"
    grep -v '^@prefix' "$file" >> "$OUTPUT_FILE"
    echo -e "\n" >> "$OUTPUT_FILE"
  done
done

riot --validate "$OUTPUT_FILE"