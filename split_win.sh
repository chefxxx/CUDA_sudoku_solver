#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./split_sudoku_win.sh <input_file.csv>"
    exit 1
fi

INPUT_FILE="$1"
PUZZLE_OUT="puzzles.csv"
SOL_OUT="solutions.csv"

echo "Processing $INPUT_FILE for Windows format..."

# 1. Extract, 2. Add \r to end of line, 3. Save
tail -n +2 "$INPUT_FILE" | cut -d ',' -f 1 | sed 's/$/\r/' > "$PUZZLE_OUT"
echo "✅ Puzzles saved to $PUZZLE_OUT (CRLF)"

tail -n +2 "$INPUT_FILE" | cut -d ',' -f 2 | sed 's/$/\r/' > "$SOL_OUT"
echo "✅ Solutions saved to $SOL_OUT (CRLF)"