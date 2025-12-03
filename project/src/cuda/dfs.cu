//
// Created by chefxx on 02.12.2025.
//

#include "device_board.cuh"
#include "generate_boards.cuh"
#include "dfs.cuh"


__global__ void solveSudokuBoards(const CELL_TYPE *t_boardsBuff, const CONSTRAINTS_TYPE *t_constraintsBuff, const size_t t_boardCount)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_boardsBuff, MAX_GEN_BOARDS);
        constraints.initConstraints(work, t_constraintsBuff, MAX_GEN_BOARDS);


    }
}