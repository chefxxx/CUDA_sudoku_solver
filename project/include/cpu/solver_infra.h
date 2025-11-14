//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_SOLVER_H
#define CUDA_SUDOKU_SOLVER_H

#include <optional>
#include <vector>
#include "board.h"

std::vector<BoardConstraints> createBoardsConstraintsSerial(const std::vector<std::string> &t_encodedBoards);
std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(std::string_view t_line);

#endif // CUDA_SUDOKU_SOLVER_H
