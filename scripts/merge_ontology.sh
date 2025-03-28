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
  elif [ ! -s "$file" ]; then
    echo "Error: File $file is empty" >&2
    exit 1
  fi
done

# Download Schema.org ontology in Turtle format (if not present)
SCHEMA_FILE="$INPUT_DIR/imports/schema.ttl"
if [ ! -f "$SCHEMA_FILE" ]; then
  echo "Downloading Schema.org ontology..."
  wget -q https://schema.org/version/latest/schemaorg-current-https.ttl -O "$SCHEMA_FILE" || {
    echo "Error: Failed to download Schema.org ontology" >&2
    echo "Note: Schema.org provides Turtle format at https://schema.org/version/latest/schemaorg-current-https.ttl" >&2
    exit 1
  }
fi

# Create header with Schema.org import
cat > "$OUTPUT_FILE" << 'HEADER'
@prefix : <http://automobile.org/auto:#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix swrl: <http://www.w3.org/2003/11/swrl#> .       
@prefix swrlb: <http://www.w3.org/2003/11/swrlb#> .   
@prefix schema: <https://schema.org/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

<http://automobile.org/auto>
    a owl:Ontology ;
    owl:imports <./imports/schema.ttl> ;
    rdfs:label "Automobile Ontology" .

HEADER

# Merge all files
for dir in 01_core 02_instances 03_axioms; do
  for file in "$INPUT_DIR"/"$dir"/*.ttl; do
    [ -f "$file" ] || continue  # Skip if no files in dir
    echo "# Source: $file" >> "$OUTPUT_FILE"
    sed '/^@prefix/d' "$file" >> "$OUTPUT_FILE"
    echo -e "\n" >> "$OUTPUT_FILE"
  done
done

# Validation
if command -v riot >/dev/null; then
    echo -e "\nValidating ontology..."
    if riot --validate "$OUTPUT_FILE"; then
        echo "Validation successful"
    else
        echo "Validation failed - trying offline validation..."
        # Fallback to basic syntax check without imports
        if riot --check "$OUTPUT_FILE"; then
            echo "Syntax is valid (imports not checked)"
        else
            echo "Syntax validation failed" >&2
            exit 1
        fi
    fi
else
    echo "ERROR: riot is missing. Install Apache Jena for validation." >&2
    echo "Hint: apt-get install jena or brew install jena" >&2
    exit 1
fi