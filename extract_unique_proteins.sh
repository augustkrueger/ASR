#!/bin/bash

# Usage: ./extract_unique_proteins.sh input.txt

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 input.txt"
    exit 1
fi

input="$1"
output="concat_key_unique-tags.txt"

awk '
{
    desc = $0

    # Remove accession (everything up to first whitespace block)
    sub(/^[^[:space:]]+[[:space:]]+/, "", desc)

    # Remove organism info in brackets
    sub(/\[.*$/, "", desc)

    # Remove MULTISPECIES:
    sub(/^MULTISPECIES:[[:space:]]*/, "", desc)

    # Trim leading/trailing whitespace
    gsub(/^[ \t]+|[ \t]+$/, "", desc)

    if (desc != "")
        print desc
}
' "$input" | sort -u > "$output"

echo "Unique identifiers written to $output"
