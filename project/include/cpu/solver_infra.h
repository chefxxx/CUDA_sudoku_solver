//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_SOLVER_H
#define CUDA_SUDOKU_SOLVER_H

#include "board.h"
#include <vector>

std::vector<Board> createBoardsSerial(const std::vector<std::string>& t_encodedBoards);

#endif // CUDA_SUDOKU_SOLVER_H
