//
// Created by chefxx on 25.11.2025.
//

#include <cstdio>

#include "generate_boards.cuh"
#include "solver_infra.cuh"

__global__ void chooseChildren(const CELL_TYPE        *t_boardsBuff,
                               const CONSTRAINTS_TYPE *t_constraintsBuff,
                               uint16_t               *t_childrenBuff,
                               const int              *t_boardCount)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;
    const size_t N          = *t_boardCount;

    __shared__ DeviceConstraints constraints[THREADS_PER_BLOCK];

    for (size_t work = tid; work < N; work += workOffset) {
        const auto board = createDeviceBoard(work, t_boardsBuff);

    }
}

__global__ void createChildren() {}

__device__ DeviceBoard createDeviceBoard(const size_t t_workId, const CELL_TYPE *t_boardsBuff)
{
    DeviceBoard board;
#pragma unroll
    for (size_t k = 0; k < SUDOKU_BITPACK_N; ++k) {
        board.cells[k] = t_boardsBuff[t_workId + k * MAX_GEN_BOARDS];
    }
    return board;
}
