//
// Created by chefxx on 12.11.2025.
//

#include <cassert>
#include <fstream>

#include "defines.h"
#include "host_board.h"
#include "io_manager.h"
#include "spdlog/spdlog.h"


std::vector<std::string> readInput(std::string_view t_inputFileName, const int t_count)
{
    char   *line = nullptr;
    size_t  len  = 0;
    ssize_t read;

    FILE *fp = fopen(t_inputFileName.data(), "r");
    if (fp == nullptr) {
        spdlog::error("Failed to open file {}!", t_inputFileName);
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    int                      lineIdx = 1;
    int                      readIdx = 0;
    while ((read = getline(&line, &len, fp)) != -1 && readIdx < t_count) {
        if (read != SUDOKU_SIZE * SUDOKU_SIZE + 2) {
            spdlog::error("Wrong number of characters in the line {} of the input file!", lineIdx);
        }
        else {
            lines.emplace_back(line);
            ++readIdx;
        }
        ++lineIdx;
    }

    fclose(fp);
    if (line)
        free(line);
    if (readIdx < t_count - 1) {
        spdlog::error("Too few valid lines in the input file!");
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
        spdlog::error("Failed to open file {}!", t_outputFileName);
        exit(EXIT_FAILURE);
    }

    Board tmp;
    for (size_t i = 0; i < t_count; ++i) {
        tmp.initBoard(i, t_resultBoards, t_globalStride);
        const auto str = tmp.getBoardString();
        fprintf(fp, "%s\r\n", str.c_str());
    }
    fclose(fp);
}
