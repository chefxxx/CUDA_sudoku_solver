//
// Created by chefxx on 12.11.2025.
//

#include "io_manager.h"

#include <cassert>
#include <fstream>

#include "board.h"
#include "spdlog_macros.h"

std::vector<std::string> readInput(const std::string &t_inputFileName, const int t_count)
{
    char   *line = nullptr;
    size_t  len  = 0;
    ssize_t read;

    FILE *fp = fopen(t_inputFileName.c_str(), "r");
    if (fp == nullptr) {
        myLog::err("Could not open the file " + t_inputFileName + "!");
        exit(EXIT_FAILURE);
    }

    std::vector<std::string> lines;
    int                      lineIdx = 1;
    int                      readIdx = 0;
    while ((read = getline(&line, &len, fp)) != -1 && readIdx < t_count - 1) {
        if (read != SUDOKU_SIZE * SUDOKU_SIZE) {
            myLog::warn("Wrong number of characters in the line " + std::to_string(lineIdx) + " of the input file!");
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
