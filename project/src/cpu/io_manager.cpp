//
// Created by chefxx on 12.11.2025.
//

#include "io_manager.h"

#include <cassert>
#include <fstream>
#include <iostream>

#include "board.h"

std::vector<std::string> readInput(const std::string &t_inputFileName, const int t_count)
{
    std::ifstream inputFile(t_inputFileName);
    if (!inputFile.is_open()) {
        std::cerr << "ERROR: Could not open file " << t_inputFileName << '\n';
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    std::string              line;
    int                      line_idx = 0;
    while (std::getline(inputFile, line) && line_idx < t_count) {
        if (line.size() != SUDOKU_9 * SUDOKU_9) {
            std::cerr << "WARNING: readInput() - Line has inconsistent number of entries!\n";
            --line_idx; // this way we ensure to read "count" number of sudoku boards
        }
        else {
            lines.push_back(line);
            ++line_idx;
        }
    }
    if (static_cast<int>(lines.size()) < t_count)
        std::cerr << "WARNING: Input file contains just " << lines.size() << " valid line(s) out of " << t_count
                  << " to be read..\n";
    return lines;
}
