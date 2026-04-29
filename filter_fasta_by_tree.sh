#!/usr/bin/env bash
# filter_fasta_by_tree.sh
# Usage: ./filter_fasta_by_tree.sh <treefile> <input.fasta>
#
# Filters a FASTA file to only include sequences whose IDs are present
# in the given Newick tree file.
# Output is written to <treefile_basename>_tree-filtered.fasta

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

# Derive output name from the treefile: strip directory and any extension, append suffix
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
# Newick tip labels are comma/paren/colon/semicolon-delimited tokens.
# This strips all Newick punctuation and numeric branch lengths,
# leaving only tip label strings.
TREE_IDS=$(grep -oP "[A-Za-z0-9_.|\-]+" "$TREEFILE" \
    | grep -vP "^[0-9]*\.?[0-9]+$")   # drop pure numeric branch lengths

if [[ -z "$TREE_IDS" ]]; then
    echo "Error: No tip labels found in tree file: $TREEFILE" >&2
    exit 1
fi

TREE_ID_COUNT=$(echo "$TREE_IDS" | wc -l)
echo "Found $TREE_ID_COUNT tip labels in tree."

# --- Filter the FASTA ---
# Walk through the FASTA; print a record only if its header ID is in the tree.
awk -v ids="$TREE_IDS" '
BEGIN {
    # Load tree IDs into a lookup set
    n = split(ids, arr, "\n")
    for (i = 1; i <= n; i++) {
        gsub(/^[ \t]+|[ \t]+$/, "", arr[i])   # trim whitespace
        if (arr[i] != "") tree[arr[i]] = 1
    }
    print_seq = 0
}
/^>/ {
    # Extract the ID: everything after ">" up to the first space or end-of-line
    match($0, /^>([^ \t]+)/, m)
    seqid = m[1]
    print_seq = (seqid in tree) ? 1 : 0
    if (print_seq) print
    next
}
{
    if (print_seq) print
}
' "$INPUT_FASTA" > "$OUTPUT_FASTA"

# --- Report results ---
IN_COUNT=$(grep -c "^>" "$INPUT_FASTA" || true)
OUT_COUNT=$(grep -c "^>" "$OUTPUT_FASTA" || true)
DROPPED=$(( IN_COUNT - OUT_COUNT ))

echo "Input sequences  : $IN_COUNT"
echo "Output sequences : $OUT_COUNT"
echo "Dropped sequences: $DROPPED"
echo "Done → $OUTPUT_FASTA"
