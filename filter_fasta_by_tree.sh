#!/usr/bin/env bash
# filter_fasta_by_tree.sh
# Usage: ./filter_fasta_by_tree.sh <treefile> <input.fasta>
#
# Filters a FASTA file to only include sequences whose IDs are present
# in the given Newick tree file.
# Output is written to <treefile_basename>_tree-filtered.fasta
#
# Portable: works with BSD (macOS) and GNU grep/awk.

set -euo pipefail

# --- Argument handling ---
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <treefile> <input.fasta>" >&2
    echo "  treefile    - Newick-format tree file" >&2
    echo "  input.fasta - FASTA file to filter" >&2
    echo "  Output will be: <treefile_basename>_tree-filtered.fasta" >&2
    exit 1
fi

TREEFILE="$1"
INPUT_FASTA="$2"

TREE_BASENAME=$(basename "$TREEFILE")
TREE_STEM="${TREE_BASENAME%.*}"
OUTPUT_FASTA="${TREE_STEM}_tree-filtered.fasta"

# --- Validate inputs ---
if [[ ! -f "$TREEFILE" ]]; then
    echo "Error: Tree file not found: $TREEFILE" >&2
    exit 1
fi

if [[ ! -f "$INPUT_FASTA" ]]; then
    echo "Error: FASTA file not found: $INPUT_FASTA" >&2
    exit 1
fi

# --- Extract sequence IDs from the tree ---
IDS_FILE=$(mktemp)
trap 'rm -f "$IDS_FILE"' EXIT

# Tokenize on allowed ID characters (hyphen last in the class for POSIX ERE),
# then drop pure numeric tokens (branch lengths / support values),
# including scientific notation like 1e-05.
# "|| true" keeps pipefail from aborting if the filter removes everything.
grep -oE '[A-Za-z0-9_.|-]+' "$TREEFILE" \
    | grep -vE '^[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$' \
    | sort -u > "$IDS_FILE" || true

if [[ ! -s "$IDS_FILE" ]]; then
    echo "Error: No tip labels found in tree file: $TREEFILE" >&2
    exit 1
fi

TREE_ID_COUNT=$(wc -l < "$IDS_FILE" | tr -d ' ')
echo "Found $TREE_ID_COUNT unique tip labels in tree."

# --- Filter the FASTA ---
# First file (IDS_FILE) loads the lookup set; second file (FASTA) is filtered.
awk '
NR == FNR {
    gsub(/^[ \t\r]+|[ \t\r]+$/, "")
    if ($0 != "") tree[$0] = 1
    next
}
/^>/ {
    seqid = substr($1, 2)      # first whitespace-delimited field, minus ">"
    print_seq = (seqid in tree)
    if (print_seq) print
    next
}
{
    if (print_seq) print
}
' "$IDS_FILE" "$INPUT_FASTA" > "$OUTPUT_FASTA"

# --- Report results ---
IN_COUNT=$(grep -c "^>" "$INPUT_FASTA" || true)
OUT_COUNT=$(grep -c "^>" "$OUTPUT_FASTA" || true)
DROPPED=$(( IN_COUNT - OUT_COUNT ))

echo "Input sequences  : $IN_COUNT"
echo "Output sequences : $OUT_COUNT"
echo "Dropped sequences: $DROPPED"
echo "Done → $OUTPUT_FASTA"
