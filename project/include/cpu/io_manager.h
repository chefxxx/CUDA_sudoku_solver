//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_INPUT_READER_H
#define CUDA_SUDOKU_INPUT_READER_H

#include <fstream>
#include <string>
#include <vector>
#include <tuple>

std::tuple<std::vector<std::string>, size_t> readInput(const std::string& t_inputFileName);
void writeOutput(const std::string& t_outputFileName);

#endif // CUDA_SUDOKU_INPUT_READER_H
