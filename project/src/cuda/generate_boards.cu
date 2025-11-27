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

    DeviceBoard board;
    DeviceConstraints constraints;

    for (size_t work = tid; work < N; work += workOffset) {
        board.initBoard(work, t_boardsBuff, MAX_GEN_BOARDS);
        constraints.initConstraints(work, t_constraintsBuff, MAX_GEN_BOARDS);
        const auto minIdx = findMostConstrainedCell(board, constraints);
    }
}

__device__ __forceinline__ uint16_t findMostConstrainedCell(const DeviceBoard       &t_board,
                                                            const DeviceConstraints &t_constraints)
{
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        const auto value = t_board.getValue(i);
    }
}

__device__ __forceinline__ void storeDeviceConstraints(const size_t            t_workId,
                                       const CONSTRAINTS_TYPE *t_constraintsBuff,
                                       DeviceConstraints      *t_sharedConstraintsBuff,
                                       const size_t            t_tid)
{
    for (int i = 0; i < CONSTRAINTS_N; ++i) {
        for (size_t k = 0; k < SUDOKU_SIZE; ++k) {
            t_sharedConstraintsBuff[t_tid].cells[i][k] =
                t_constraintsBuff[t_workId + i * MAX_GEN_BOARDS * SUDOKU_SIZE + k * MAX_GEN_BOARDS];
        }
    }
}
