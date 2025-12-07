//
// Created by chefxx on 25.11.2025.
//

#include "bit_operations.cuh"
#include "generate_boards.cuh"
#include "solver_infra.cuh"

__global__ void chooseChildren(const CELL_TYPE        *t_boardsBuff,
                               const CONSTRAINTS_TYPE *t_constraintsBuff,
                               uint32_t               *t_childrenBuff,
                               uint16_t               *t_cellNumsBuff,
                               const size_t            t_boardCount,
                               const size_t                  t_globalStride)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_boardsBuff, t_globalStride);
        constraints.initConstraints(work, t_constraintsBuff, t_globalStride);
        uint16_t cellIdx, minChildNum;
        findMostConstrainedCell(board, constraints, cellIdx, minChildNum);
        t_childrenBuff[work] = minChildNum;
        t_cellNumsBuff[work] = cellIdx;
    }
}

__global__ void createChildren(const CELL_TYPE        *t_inBoardsBuff,
                               CELL_TYPE              *t_outBoardsBuff,
                               const CONSTRAINTS_TYPE *t_inConstraintsBuff,
                               CONSTRAINTS_TYPE       *t_outConstraintsBuff,
                               const uint32_t         *t_inRootsBuff,
                               uint32_t               *t_outRootsBuff,
                               const uint32_t         *t_offsetBuff,
                               const uint16_t         *t_cellNumsBuff,
                               const size_t            t_boardCount,
                               const size_t            t_globalStride)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_inBoardsBuff, t_globalStride);
        constraints.initConstraints(work, t_inConstraintsBuff, t_globalStride);
        const uint32_t offset = t_offsetBuff[work];
        const uint32_t root   = t_inRootsBuff[work];
        const uint16_t cell   = t_cellNumsBuff[work];
        createAndAlignInBuff(
            t_outBoardsBuff, t_outConstraintsBuff, t_outRootsBuff, offset, root, cell, board, constraints, t_globalStride);
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
            const auto             idx  = getConstraintsIndexesInfra(i);
            const CONSTRAINTS_TYPE mask = t_constraints.cells[row][idx.row] & t_constraints.cells[col][idx.col]
                                        & t_constraints.cells[square][idx.square];
            const auto childNum = popCount(mask);
            if (childNum < t_minChildNum) {
                t_minChildNum = childNum;
                t_cellIdx     = i;
            }
        }
    }
}
