//
// Created by chefxx on 02.12.2025.
//

#include "dfs.cuh"

__global__ void solveSudokuBoards(const CELL_TYPE        *t_inBoardsBuff,
                                  CELL_TYPE              *t_outBoardsBuff,
                                  const CONSTRAINTS_TYPE *t_constraintsBuff,
                                  const uint32_t         *t_rootBuff,
                                  const size_t            t_boardCount)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    __shared__ uint16_t emptyBuffer[MAX_STACK_SIZE * THREADS_PER_BLOCK];
    __shared__ uint16_t masksBuffer[MAX_STACK_SIZE * THREADS_PER_BLOCK];

    uint16_t* empty  = &emptyBuffer[MAX_STACK_SIZE * threadIdx.x];
    uint16_t* masks  = &masksBuffer[MAX_STACK_SIZE * threadIdx.x];

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_inBoardsBuff, MAX_GEN_BOARDS);
        constraints.initConstraints(work, t_constraintsBuff, MAX_GEN_BOARDS);

        solveOneBoard(board, constraints, empty, masks, t_outBoardsBuff, t_rootBuff[workOffset]);
    }
}