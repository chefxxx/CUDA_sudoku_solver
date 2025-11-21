//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_SOLVER_H
#define CUDA_SUDOKU_SOLVER_H

#include <optional>
#include <vector>

#include "board.h"

std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(std::string_view t_line);
std::tuple<std::vector<CELL_TYPE>, std::vector<uint16_t>, int> convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards);

#endif // CUDA_SUDOKU_SOLVER_H
