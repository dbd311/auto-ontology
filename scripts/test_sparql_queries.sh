#!/bin/bash
set -eo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validate arguments
if [ $# -ne 2 ]; then
    echo -e "${RED}Error: Invalid number of arguments${NC}" >&2
    echo -e "Usage: $0 <ontology_file> <query_directory>" >&2
    exit 1
fi

# Configurations
ONTOLOGY_FILE="$(readlink -f "$1")"
QUERY_DIR="$(readlink -f "$2")"
OUTPUT_DIR="$(pwd)/sparql_results"
LOG_FILE="$(pwd)/sparql_run.log"

# Validate environment
if [ ! -f "$ONTOLOGY_FILE" ]; then
    echo -e "${RED}Error: Ontology file missing: $ONTOLOGY_FILE${NC}" >&2
    exit 1
fi

if [ ! -d "$QUERY_DIR" ]; then
    echo -e "${RED}Error: Query directory missing: $QUERY_DIR${NC}" >&2
    exit 1
fi

if ! command -v sparql >/dev/null 2>&1; then
    echo -e "${RED}Error: 'sparql' command not found. Install with:${NC}" >&2
    echo -e "sudo apt-get install rasqal-utils" >&2
    exit 1
fi

# Initialize
mkdir -p "$OUTPUT_DIR"
> "$LOG_FILE"
processed=0
errors=0

# Get query files - WSL compatible method
echo -e "\n${YELLOW}Finding query files...${NC}"
IFS=$'\n' queries=($(find "$QUERY_DIR" -type f \( -name "*.rq" -o -name "*.sparql" \) | sort))
total_queries=${#queries[@]}

if [ "$total_queries" -eq 0 ]; then
    echo -e "${RED}Error: No query files found (*.rq or *.sparql)${NC}" >&2
    exit 1
fi

echo -e "${GREEN}Starting processing of $total_queries queries...${NC}"
# Process files - simplified loop
for ((i=0; i<${#queries[@]}; i++)); do
    query="${queries[$i]}"
    processed=$((processed + 1))
    query_name=$(basename "$query")
    output_file="$OUTPUT_DIR/${query_name%.*}.json"
   
    echo -e "[$processed/$total_queries] Processing: ${GREEN}$query_name${NC}"
    echo "[$processed/$total_queries] Processing: $query_name" >> "$LOG_FILE"
    
    if ! sparql --data "$ONTOLOGY_FILE" --query "$query" > "$output_file" 2>> "$LOG_FILE"; then
        echo -e "${RED}ERROR: Failed $query_name${NC}" >&2
        echo "ERROR: Failed $query_name" >> "$LOG_FILE"
        rm -f "$output_file"
        error=$((errors + 1))
        continue
    fi
    
    if command -v jq >/dev/null 2>&1 && ! jq empty "$output_file" 2>/dev/null; then
        echo -e "${YELLOW}WARNING: Invalid JSON output for $query_name${NC}" >&2
        echo "WARNING: Invalid JSON output for $query_name" >> "$LOG_FILE"
    fi
done

# Final report
echo "----------------------------------------"
echo "Summary:"
echo "Processing time: $SECONDS seconds"
echo "Total queries found: $total_queries"
echo "Successfully processed: $((processed - errors))"
echo "Failed queries: $errors"

if [ "$errors" -gt 0 ]; then
    echo -e "${RED}Validation completed with $errors errors${NC}" >&2
    exit 1
else
    echo -e "${GREEN}Validation completed successfully${NC}"
    exit 0
fi