//
// Created by chefxx on 25.11.2025.
//

#include "generate_boards.cuh"
#include "solver_infra.cuh"

__global__ void chooseChildren(const CELL_TYPE        *t_boardsBuff,
                               const CONSTRAINTS_TYPE *t_constraintsBuff,
                               uint16_t               *t_childrenBuff,
                               uint16_t               *t_cellNumsBuff,
                               const int              *t_boardCount)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;
    const size_t N          = *t_boardCount;

    DeviceBoard       board;
    DeviceConstraints constraints;

    for (size_t work = tid; work < N; work += workOffset) {
        board.initBoard(work, t_boardsBuff, MAX_GEN_BOARDS);
        constraints.initConstraints(work, t_constraintsBuff, MAX_GEN_BOARDS);
        uint16_t cellIdx, minChildNum;
        findMostConstrainedCell(board, constraints, cellIdx, minChildNum);
        t_childrenBuff[work] = minChildNum;
        t_cellNumsBuff[work] = cellIdx;
    }
}

__device__ void findMostConstrainedCell(const DeviceBoard       &t_board,
                                        const DeviceConstraints &t_constraints,
                                        uint16_t                &t_cellIdx,
                                        uint16_t                &t_minChildNum)
{
    t_cellIdx = 0;
    t_minChildNum = 10;
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        const auto value = t_board.getValue(i);
        if (!value) {
            const auto idx = t_constraints.getConstraintsIndexes(i);
            const auto mask = t_constraints.cells[row][idx.row] & t_constraints.cells[col][idx.col]
                            & t_constraints.cells[square][idx.square];
            const auto childNum = __popc(mask);
            if (childNum < t_minChildNum) {
                t_minChildNum = childNum;
                t_cellIdx = i;
            }
        }
    }
}

__device__ void storeDeviceConstraints(const size_t            t_workId,
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
