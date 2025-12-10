#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
    echo "Usage: ./split_sudoku.sh <input_file.csv>"
    exit 1
fi

INPUT_FILE="$1"
PUZZLE_OUT="puzzles.txt"
SOL_OUT="solutions.txt"

echo "Processing $INPUT_FILE..."

# Extract puzzles (skip header, cut col 1)
tail -n +2 "$INPUT_FILE" | cut -d ',' -f 1 > "$PUZZLE_OUT"
echo "✅ Puzzles saved to $PUZZLE_OUT"

# Extract solutions (skip header, cut col 2)
tail -n +2 "$INPUT_FILE" | cut -d ',' -f 2 > "$SOL_OUT"
echo "✅ Solutions saved to $SOL_OUT"