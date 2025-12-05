//
// Created by chefxx on 12.11.2025.
//

#include "io_manager.h"

#include <cassert>
#include <fstream>

#include "defines.h"
#include "spdlog_macros.h"

std::vector<std::string> readInput(std::string_view t_inputFileName, const int t_count)
{
    char   *line = nullptr;
    size_t  len  = 0;
    ssize_t read;

    FILE *fp = fopen(t_inputFileName.data(), "r");
    if (fp == nullptr) {
        myLog::err(fmt::format("Failed to open file {}!", t_inputFileName));
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    int                      lineIdx = 1;
    int                      readIdx = 0;
    while ((read = getline(&line, &len, fp)) != -1 && readIdx < t_count) {
        if (read != SUDOKU_SIZE * SUDOKU_SIZE + 2) {
            myLog::warn(fmt::format("Wrong number of characters in the line {} of the input file!", lineIdx));
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
        myLog::warn("Too few valid lines in the input file!");
    }
    return lines;
}
