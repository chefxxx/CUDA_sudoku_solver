//
// Created by chefxx on 12.11.2025.
//

#include <fstream>
#include <iostream>
#include "defines.h"
#include "host_board.h"
#include "io_manager.h"

std::vector<std::string> readInput(std::string_view t_inputFileName, const int t_count)
{
    std::ifstream file(t_inputFileName.data());

    if (!file.is_open()) {
        std::cout << "Failed to open file!\n";
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    std::string currentLine;
    int lineIdx = 1;
    int readIdx = 0;

    while (readIdx < t_count && std::getline(file, currentLine)) {
        if (!currentLine.empty() && currentLine.back() == '\r') {
            currentLine.pop_back();
        }

        if (currentLine.length() != SUDOKU_SIZE * SUDOKU_SIZE) {
            std::cout << "Wrong number of characters in the input file!\n";
        } else {
            lines.emplace_back(currentLine);
            ++readIdx;
        }
        ++lineIdx;
    }

    if (readIdx < t_count) {
        std::cout << "Too few valid lines in the input file!\n";
    }

    return lines;
}

void writeOutput(const std::string_view        t_outputFileName,
                 const std::vector<CELL_TYPE> &t_resultBoards,
                 const size_t                  t_globalStride,
                 const size_t                  t_count)
{
    FILE *fp = fopen(t_outputFileName.data(), "w");
    if (fp == nullptr) {
        std::cout << "Failed to open file!\n";
        exit(EXIT_FAILURE);
    }

    Board tmp;
    for (size_t i = 0; i < t_count; ++i) {
        tmp.initBoard(i, t_resultBoards, t_globalStride);
        const auto str = tmp.getBoardString();
        fprintf(fp, "%s\n", str.c_str());
    }
    fclose(fp);
}
