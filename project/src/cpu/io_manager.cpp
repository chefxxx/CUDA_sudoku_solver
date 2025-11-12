//
// Created by chefxx on 12.11.2025.
//

#include "io_manager.h"
#include "board.h"

std::vector<std::string> readInput(const std::string& t_inputFileName)
{
    std::ifstream inputFile(t_inputFileName);
    if (!inputFile.is_open()) {
        std::cerr << "ERROR: Could not open file " << t_inputFileName << "\n";
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    std::string line;
    while (std::getline(inputFile, line)) {
        assert(line.size() == PUZZLE_9 * PUZZLE_9 || line.size() == PUZZLE_16 * PUZZLE_16);
        lines.push_back(line);
    }
    return lines;
}