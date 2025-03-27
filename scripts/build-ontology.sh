#!/bin/bash

# Robust Ontology Merger with Validation

# Configuration
INPUT_DIR="${1:-../}"
OUTPUT_FILE="${2:-automobile_ontology.ttl}"
BASE_URI="http://automobile.org/auto#"

# Initialize counters
declare -i files_processed=0
declare -i files_failed=0

validate_file() {
    local file="$1"
    [ -f "$file" ] || { echo "Error: Missing file: $file" >&2; return 1; }
    [ -r "$file" ] || { echo "Error: Unreadable file: $file" >&2; return 1; }
    
    # Check encoding (skip binary files)
    local encoding=$(file -b --mime-encoding "$file")
    [[ "$encoding" =~ "utf-8"|"us-ascii" ]] || {
        echo "Warning: Non-standard encoding in $file ($encoding)" >&2
        return 2
    }
    return 0
}

merge_content() {
    local file="$1"
    echo "# Source: $(basename "$file")" >> "$OUTPUT_FILE"
    grep -v -e '^@prefix' -e '^#' "$file" | dos2unix >> "$OUTPUT_FILE"
    echo -e "\n" >> "$OUTPUT_FILE"
    ((files_processed++))
}

merge_ontology() {
    # Create output directory
    mkdir -p "$(dirname "$OUTPUT_FILE")"
    
    # Write header
    cat > "$OUTPUT_FILE" << HEADER
@prefix : <${BASE_URI}> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix swrl: <http://www.w3.org/2003/11/swrl#> .
@prefix swrlb: <http://www.w3.org/2003/11/swrlb#> .

<${BASE_URI}>
    a owl:Ontology ;
    rdfs:label "Automobile Ontology" .

HEADER

    # Required files checklist
    declare -A required_files=(
        ["Core Classes"]="01_core/01_classes.ttl"
        ["Object Properties"]="01_core/02_object_properties.ttl"
        ["Data Properties"]="01_core/03_data_properties.ttl"
        ["Engines"]="02_instances/02_engines.ttl"
        ["Restrictions"]="03_axioms/01_restrictions.ttl"
    )

    # Optional files (wildcard patterns)
    declare -A optional_files=(
        ["Manufacturers"]="02_instances/01_manufacturers_*.ttl"
        ["Vehicles"]="02_instances/03_vehicles_*.ttl"
        ["SWRL Rules"]="03_axioms/02_swrl_rules.ttl"
    )

    # Process required files
    for label in "${!required_files[@]}"; do
        file="${required_files[$label]}"
        full_path="${INPUT_DIR}/${file}"
        
        if validate_file "$full_path"; then
            echo "Merging $label..."
            merge_content "$full_path"
        else
            echo "Error: Required file missing: $file" >&2
            ((files_failed++))
        fi
    done

    # Process optional files
    for label in "${!optional_files[@]}"; do
        pattern="${optional_files[$label]}"
        found=0
        
        echo "Merging $label..."
        for file in "${INPUT_DIR}/"${pattern}; do
            if validate_file "$file"; then
                merge_content "$file"
                found=1
            fi
        done
        
        [ $found -eq 0 ] && echo "Warning: No $label files found" >&2
    done

    # Final report
    echo -e "\nMerge completed:"
    echo "- Files processed: $files_processed"
    echo "- Files failed/missing: $files_failed"
    
    # Validation
    if command -v riot >/dev/null; then
        echo -e "\nValidating ontology..."
        if riot --validate "$OUTPUT_FILE"; then
            echo "Validation successful"
            return 0
        else
            echo "Validation failed" >&2
            return 1
        fi
    else
        echo "Note: Install riot (Apache Jena) for validation"
        return 0
    fi
}

# Main execution
merge_ontology
exit $?