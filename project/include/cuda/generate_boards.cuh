//
// Created by chefxx on 25.11.2025.
//

#ifndef CUDA_SUDOKU_GENERATE_BOARDS_H
#define CUDA_SUDOKU_GENERATE_BOARDS_H

#include <cstdint>
#include "board.h"

__global__ void chooseChildren(CELL_TYPE *t_boardsBuff, uint16_t *t_constraintsBuff, uint16_t *t_childrenBuff, const int *t_boardCount);
__global__ void createChildren();

#endif


