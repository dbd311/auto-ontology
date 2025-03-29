#!/bin/bash
set -eo pipefail

ONTOLOGY_FILE=$1

# Syntax Validation
if command -v riot >/dev/null; then
    echo -e "\nValidating ontology..."
    if riot --validate "$ONTOLOGY_FILE"; then
        echo "Syntax validation successful"
    else
        echo "Validation failed - trying offline validation..."
        # Fallback to basic syntax check without imports
        if riot --check "$ONTOLOGY_FILE"; then
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


# Structural Validation" or "Consistency Checking" 
# Define a simple validation SPARQL query
VALIDATION_QUERY=$(cat << 'EOF'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

SELECT DISTINCT ?type ?entity
WHERE {
  {
    ?entity a ?type .
    FILTER(ISIRI(?entity))
  } UNION {
    ?subject ?predicate ?entity .
    FILTER(ISLITERAL(?entity))
    BIND("Literal" AS ?type)
  }
}
LIMIT 100
EOF
)

# Run validation query
echo "Running basic ontology validation..."
OUTPUT_DIR="./sparql_results"
validation_output="$OUTPUT_DIR/validation_$(date +%Y%m%d_%H%M%S).tsv"

#sparql --data "$ONTOLOGY_FILE" --query <(echo "$VALIDATION_QUERY") --results TSV > "$validation_output"
sparql --data "$ONTOLOGY_FILE" --query <(echo "$VALIDATION_QUERY") --results TSV 

# Check results
if [ $? -eq 0 ]; then
    echo -e "\033[32mStructural Validation successful, i.e. we can run SPARQL query against the ontology.\033[0m"
    #echo "Results saved to $validation_output"
    #echo "Sample results:"
    #head -n 5 "$validation_output"
else
    echo -e "\033[31mValidation failed\033[0m" >&2
    exit 1
fi