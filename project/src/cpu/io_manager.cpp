//
// Created by chefxx on 12.11.2025.
//

#include "io_manager.h"

#include <cassert>
#include <fstream>
#include <iostream>
#include <spdlog/spdlog.h>

#include "board.h"

std::vector<std::string> readInput(const std::string &t_inputFileName, const int t_count)
{
    std::ifstream inputFile(t_inputFileName);
    if (!inputFile.is_open()) {
        spdlog::error("Could not open the file {}", t_inputFileName);
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    std::string              line;
    int                      lineIdx = 1;
    int                      readIdx = 0;
    while (std::getline(inputFile, line) && readIdx < t_count) {
        if (line.size() != SUDOKU_SIZE * SUDOKU_SIZE) {
            spdlog::warn("readInput() - LINE:{} has inconsistent number of entries!", lineIdx);
            --readIdx; // this way we ensure to read "count" number of sudoku boards
        }
        else {
            lines.push_back(line);
            ++readIdx;
        }
        lineIdx++;
    }
    if (static_cast<int>(lines.size()) < t_count)
        spdlog::warn("readInput() - Input file contains just {} line(s) that have proper length out of {} to be read.",
                     lines.size(),
                     t_count);
    return lines;
}
