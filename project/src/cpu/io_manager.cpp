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
    int                      lineIdx = 1;
    int                      readIdx = 0;
    while (std::getline(inputFile, line) && readIdx < t_count) {
        if (line.size() != SUDOKU_SIZE * SUDOKU_SIZE) {
            std::cerr << "WARNING: readInput() - LINE:" << lineIdx << " has inconsistent number of entries!\n";
            --readIdx; // this way we ensure to read "count" number of sudoku boards
        }
        else {
            lines.push_back(line);
            ++readIdx;
        }
        lineIdx++;
    }
    if (static_cast<int>(lines.size()) < t_count)
        std::cerr << "WARNING: readInput() - Input file contains just " << lines.size() << " valid line(s) out of "
                  << t_count << " to be read..\n";
    return lines;
}
