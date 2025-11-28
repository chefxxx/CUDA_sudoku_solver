//
// Created by chefxx on 25.11.2025.
//

#include "generate_boards.cuh"
#include "solver_infra.cuh"

__global__ void chooseChildren(const CELL_TYPE        *t_boardsBuff,
                               const CONSTRAINTS_TYPE *t_constraintsBuff,
                               uint32_t               *t_childrenBuff,
                               uint16_t               *t_cellNumsBuff,
                               const size_t            t_boardCount)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_boardsBuff, MAX_GEN_BOARDS);
        constraints.initConstraints(work, t_constraintsBuff, MAX_GEN_BOARDS);
        uint16_t cellIdx, minChildNum;
        findMostConstrainedCell(board, constraints, cellIdx, minChildNum);
        t_childrenBuff[work] = minChildNum;
        t_cellNumsBuff[work] = cellIdx;
    }
}

__global__ void createChildren(const CELL_TYPE        *t_inBoardsBuff,
                               const CELL_TYPE        *t_outBoardsBuff,
                               const CONSTRAINTS_TYPE *t_inConstraintsBuff,
                               const CONSTRAINTS_TYPE *t_outConstraintsBuff,
                               const uint32_t         *t_offsetBuff,
                               const uint16_t         *t_cellNumsBuff,
                               const size_t            t_boardCount)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_inBoardsBuff, MAX_GEN_BOARDS);
        constraints.initConstraints(work, t_inConstraintsBuff, MAX_GEN_BOARDS);
    }
}

__device__ void findMostConstrainedCell(const DeviceBoard       &t_board,
                                        const DeviceConstraints &t_constraints,
                                        uint16_t                &t_cellIdx,
                                        uint16_t                &t_minChildNum)
{
    t_cellIdx     = 0;
    t_minChildNum = 10;
#pragma unroll
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        const auto value = t_board.getValue(i);
        if (!value) {
            const auto     idx        = getConstraintsIndexesInfra(i);
            const uint32_t rowMask    = t_constraints.cells[row][idx.row];
            const uint32_t colMask    = t_constraints.cells[col][idx.col];
            const uint32_t squareMask = t_constraints.cells[square][idx.square];
            const uint32_t mask       = rowMask & colMask & squareMask;
            const auto     childNum   = __popc(mask);
            if (childNum < t_minChildNum) {
                t_minChildNum = childNum;
                t_cellIdx     = i;
            }
        }
    }
}


