#!/bin/bash

# 1. Check arguments
if [ -z "$1" ]; then
    echo "Usage: ./split_filter_sudoku.sh <input_file.csv>"
    exit 1
fi

INPUT_FILE="$1"
TEMP_FILE="temp_filtered.csv"
PUZZLE_OUT="puzzles.csv"
SOL_OUT="solutions.csv"

# Threshold for empty cells (zeros)
MIN_ZEROS=40

echo "filtering $INPUT_FILE for puzzles with >= $MIN_ZEROS zeros..."

# 2. Filter using AWK
# -F,  : Sets delimiter to comma
# NR>1 : Skips the header row
# gsub : Counts occurrences of '0' in the first column ($1)
awk -F, -v limit="$MIN_ZEROS" 'NR > 1 {
    # Make a copy of the puzzle string so we do not modify the original line
    puzzle = $1;
    # gsub returns the number of substitutions made.
    # We replace "0" with nothing to count them.
    zeros = gsub(/0/, "", puzzle);

    # If zeros count is >= limit, print the original full line
    if (zeros >= limit) {
        print $0;
    }
}' "$INPUT_FILE" > "$TEMP_FILE"

# Count how many passed the filter
COUNT=$(wc -l < "$TEMP_FILE")
echo "Found $COUNT puzzles matching criteria."

# 3. Extract, Format for Windows, and Save
echo "Splitting into output files..."

# Extract Puzzles (Column 1)
cut -d ',' -f 1 "$TEMP_FILE" | sed 's/$/\r/' > "$PUZZLE_OUT"
echo "✅ Puzzles saved to $PUZZLE_OUT (CRLF)"

# Extract Solutions (Column 2)
cut -d ',' -f 2 "$TEMP_FILE" | sed 's/$/\r/' > "$SOL_OUT"
echo "✅ Solutions saved to $SOL_OUT (CRLF)"

# 4. Cleanup
rm "$TEMP_FILE"