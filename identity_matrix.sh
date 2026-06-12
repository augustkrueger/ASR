#!/usr/bin/env bash
# identity_matrix.sh — convert pairwise identity file to lower-triangle TSV matrix
# input .txt file is output of seqcon -I
#
# Usage:
#   ./identity_matrix.sh input.txt              # prints to stdout
#   ./identity_matrix.sh input.txt output.tsv   # writes to file
#
# Input format: whitespace-delimited, three columns per line
#   seq1   seq2   0.95633188

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <input.txt> [output.tsv]" >&2
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-}"

if [[ ! -f "$INPUT" ]]; then
    echo "Error: file not found: $INPUT" >&2
    exit 1
fi

python3 - "$INPUT" <<'PYEOF'
import sys
from collections import OrderedDict

infile = sys.argv[1]
data = {}
order = OrderedDict()

with open(infile) as fh:
    for line in fh:
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) < 3:
            continue
        a, b, v = parts[0], parts[1], parts[2]
        try:
            v = float(v)
        except ValueError:
            continue
        order[a] = None
        order[b] = None
        data[(a, b)] = v
        data[(b, a)] = v

labels = list(order.keys())
n = len(labels)

rows = []

header = [""] + labels
rows.append(header)

for i, row in enumerate(labels):
    cells = [row]
    for j, col in enumerate(labels):
        if j > i:
            cells.append("")
        elif i == j:
            cells.append("1.0000")
        else:
            v = data.get((row, col))
            cells.append(f"{v:.4f}" if v is not None else "")
    rows.append(cells)

out = "\n".join("\t".join(r) for r in rows)
print(out)
PYEOF
