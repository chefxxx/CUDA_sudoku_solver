//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_INPUT_READER_H
#define CUDA_SUDOKU_INPUT_READER_H

#include <string>
#include <vector>

#include "defines.h"

std::vector<std::string> readInput(std::string_view t_inputFileName, int t_count);
void                     writeOutput(std::string_view              t_outputFileName,
                                     const std::vector<CELL_TYPE> &t_resultBoards,
                                     size_t                        t_globalStride,
                                     size_t                        t_count);

#endif // CUDA_SUDOKU_INPUT_READER_H
