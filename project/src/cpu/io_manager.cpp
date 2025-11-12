//
// Created by chefxx on 12.11.2025.
//

#include <tuple>
#include "io_manager.h"
#include "board.h"

std::tuple<std::vector<std::string>, size_t> readInput(const std::string &t_inputFileName)
{
    std::ifstream inputFile(t_inputFileName);
    if (!inputFile.is_open()) {
        std::cerr << "ERROR: Could not open file " << t_inputFileName << "\n";
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    std::string              line;
    std::getline(inputFile, line);

    // ---------------------------------------------------
    // Check what sudoku size is encoded in the input file,
    // all boards have to be the same size
    // ---------------------------------------------------
    size_t lineSize;
    size_t puzzleSize;

    switch (line.size()) {
    case PUZZLE_9 *PUZZLE_9:
        lineSize   = PUZZLE_9 * PUZZLE_9;
        puzzleSize = PUZZLE_9;
        break;
    case PUZZLE_16 *PUZZLE_16:
        lineSize   = PUZZLE_16 * PUZZLE_16;
        puzzleSize = PUZZLE_16;
        break;
    default:
        std::cerr << "ERROR: Not recognized board size in file " << t_inputFileName << "!\n";
        exit(EXIT_FAILURE);
    }

    lines.push_back(line);

    while (std::getline(inputFile, line)) {
        assert(line.size() == lineSize);
        lines.push_back(line);
    }
    return std::make_tuple(lines, puzzleSize);
}
