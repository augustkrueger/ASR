#!/usr/bin/env bash
# filter_not-this-resi.sh
#
# Given an aligned FASTA file, an alignment position (1-based),
# and an amino acid character, output a FASTA containing only
# sequences that DO NOT have that amino acid at that position.
# Also writes a txt file listing those same sequences and what residue they have.
#
# Usage:
#   ./filter_not-this-resi.sh aligned.fasta 145 H
#
# Example:
#   ./filter_not-this-resi.sh msa.fasta 87 D
#   -> msa_pos87_not_D.fasta
#   -> msa_pos87_not_D.txt

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

# Derive output filenames
BASENAME=$(basename "$FASTA" | sed 's/\.[^.]*$//')
OUTFASTA="${BASENAME}_pos${POSITION}_not_${AA}.fasta"
REPORT="${BASENAME}_pos${POSITION}_not_${AA}.txt"

# Process the FASTA
awk -v pos="$POSITION" -v aa="$AA" -v report="$REPORT" -v outfasta="$OUTFASTA" '
BEGIN {
    header = ""
    seq = ""
    print "Sequences without " aa " at position " pos " (residue found shown):" > report
    print "----------------------------------------" >> report
}
/^>/ {
    if (header != "") {
        residue = toupper(substr(seq, pos, 1))
        if (residue != aa) {
            print header > outfasta
            print seq > outfasta
            label = substr(header, 2)
            print label "\t" residue >> report
        }
    }
    header = $0
    seq = ""
    next
}
{
    gsub(/[[:space:]]/, "", $0)
    seq = seq $0
}
END {
    if (header != "") {
        residue = toupper(substr(seq, pos, 1))
        if (residue != aa) {
            print header > outfasta
            print seq > outfasta
            label = substr(header, 2)
            print label "\t" residue >> report
        }
    }
}
' "$FASTA"

echo "Filtered FASTA written to: $OUTFASTA" >&2
echo "Sequences report written to: $REPORT" >&2
