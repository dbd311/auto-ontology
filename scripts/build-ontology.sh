#!/bin/bash
# ln -s /mnt/c/Users/...../Documents/.../auto-ontology auto-ontology; cd auto-ontology

set -euo pipefail 
# Define input/output directories
INPUT_DIR="../"
OUTPUT_FILE="automobile_onto.ttl"

# Ensure output file is empty
> "$OUTPUT_FILE"

# Function to merge files with newline separation
merge_with_newlines() {
    for file in "$@"; do
        echo $file
        [ -e "$file" ] || continue  # Skip if file doesn't exist
        cat "$file"
        echo ""  # Add newline after each file
    done
}

# Merge core files (classes, properties)
merge_with_newlines \
    "$INPUT_DIR"/01_core/01_classes.ttl \
    "$INPUT_DIR"/01_core/02_object_properties.ttl \
    "$INPUT_DIR"/01_core/03_data_properties.ttl \
    >> "$OUTPUT_FILE"

# Merge manufacturer files (handle wildcard expansion safely)
merge_with_newlines \
    "$INPUT_DIR"/02_instances/01_manufacturers.*.ttl \
    >> "$OUTPUT_FILE"

# Merge remaining files
merge_with_newlines \
    "$INPUT_DIR"/02_instances/02_engines.ttl \
    "$INPUT_DIR"/02_instances/03_vehicles.*.ttl \
    "$INPUT_DIR"/03_axioms/01_restrictions.ttl \
    "$INPUT_DIR"/03_axioms/02_swrl_rules.ttl \
    >> "$OUTPUT_FILE"


# Validate syntax (requires Apache Jena's `riot`)
if command -v riot >/dev/null 2>&1; then
    riot --validate "$OUTPUT_FILE" && echo "Validation passed: $OUTPUT_FILE"
else
    echo "Merged file created, but riot (Apache Jena) is not installed for validation."
    echo "Installing Jena ..."
    # Download a version which is available, e.g. 5.3.0
    VERSION=5.3.0
    wget https://downloads.apache.org/jena/binaries/apache-jena-$VERSION.tar.gz

    # Extract
    tar -xvzf apache-jena-$VERSION.tar.gz
    sudo mv apache-jena-$VERSION /opt/jena
    echo 'export PATH=$PATH:/opt/jena/bin' >> ~/.bashrc
    
    rm -rf  apache-jena-$VERSION.tar.gz
    echo "Please try again!"
    exit 1
fi

echo "Merged ontology saved to: $OUTPUT_FILE"