//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_INPUT_READER_H
#define CUDA_SUDOKU_INPUT_READER_H

#include <string>
#include <vector>

std::vector<std::string> readInput(std::string_view t_inputFileName, int t_count);
void                     writeOutput(std::string_view t_outputFileName);

#endif // CUDA_SUDOKU_INPUT_READER_H
