#!/usr/bin/env bash
# filter_alignment.sh
#
# Given an aligned FASTA file, an alignment position (1-based),
# and an amino acid character, output a FASTA containing only
# sequences that DO NOT have that amino acid at that position.
#
# Usage:
#   ./filter_alignment.sh aligned.fasta 145 H > filtered.fasta
#
# Example:
#   ./filter_alignment.sh msa.fasta 87 D > sequences_not_D_at_87.fasta

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <aligned.fasta> <position> <amino_acid>" >&2
    exit 1
fi

FASTA="$1"
POSITION="$2"
AA="$3"

# Validate inputs
if [[ ! -f "$FASTA" ]]; then
    echo "Error: File '$FASTA' not found." >&2
    exit 1
fi

if ! [[ "$POSITION" =~ ^[0-9]+$ ]] || [[ "$POSITION" -lt 1 ]]; then
    echo "Error: Position must be a positive integer." >&2
    exit 1
fi

# Convert amino acid to uppercase and ensure it is a single character
AA=$(echo "$AA" | tr '[:lower:]' '[:upper:]')

if [[ ${#AA} -ne 1 ]]; then
    echo "Error: Amino acid must be a single character." >&2
    exit 1
fi

# Process the FASTA
awk -v pos="$POSITION" -v aa="$AA" '
BEGIN {
    header = ""
    seq = ""
}

# When a new header is encountered, process the previous sequence
/^>/ {
    if (header != "") {
        residue = toupper(substr(seq, pos, 1))
        if (residue != aa) {
            print header
            # Print sequence in original single-line format
            print seq
        }
    }
    header = $0
    seq = ""
    next
}

# Accumulate sequence lines (handles multiline FASTA)
{
    gsub(/[[:space:]]/, "", $0)
    seq = seq $0
}

END {
    if (header != "") {
        residue = toupper(substr(seq, pos, 1))
        if (residue != aa) {
            print header
            print seq
        }
    }
}
' "$FASTA"
