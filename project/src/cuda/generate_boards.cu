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
        //printf("cell %d, children %d\n", cellIdx, minChildNum);
        t_childrenBuff[work] = minChildNum;
        t_cellNumsBuff[work] = cellIdx;
    }
}

__global__ void createChildren(const CELL_TYPE        *t_inBoardsBuff,
                               CELL_TYPE              *t_outBoardsBuff,
                               const CONSTRAINTS_TYPE *t_inConstraintsBuff,
                               CONSTRAINTS_TYPE       *t_outConstraintsBuff,
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
        createAndAlignInBuff(
            t_outBoardsBuff, t_outConstraintsBuff, t_offsetBuff[work], t_cellNumsBuff[work], board, constraints);
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
            const CONSTRAINTS_TYPE mask =
            t_constraints.cells[row][idx.row] &
            t_constraints.cells[col][idx.col] &
            t_constraints.cells[square][idx.square];
            const auto     childNum= popCount(mask);
            if (childNum < t_minChildNum) {
                t_minChildNum = childNum;
                t_cellIdx     = i;
            }
        }
    }
}

__device__ void createAndAlignInBuff(CELL_TYPE         *t_outBoardsBuff,
                                     CONSTRAINTS_TYPE  *t_outConstraintsBuff,
                                     const uint32_t     t_globalOffset,
                                     const uint16_t     t_cellNum,
                                     DeviceBoard       &t_parentBoard,
                                     DeviceConstraints &t_parentConstraints)
{
    const auto idx = getConstraintsIndexesInfra(t_cellNum);
    CONSTRAINTS_TYPE mask =
    t_parentConstraints.cells[row][idx.row] &
    t_parentConstraints.cells[col][idx.col] &
    t_parentConstraints.cells[square][idx.square];
    uint32_t childIdx = 0;
    while (mask) {
        const int nValue = popLsb(mask);
        t_parentConstraints.updateConstraints(nValue, idx);
        t_parentBoard.setValue(t_cellNum, nValue);
        saveBoardToBuffer(t_outBoardsBuff, t_globalOffset + childIdx, t_parentBoard.cells, MAX_GEN_BOARDS);
        saveConstraintsToBuffer(t_outConstraintsBuff, MAX_GEN_BOARDS * SUDOKU_SIZE, t_globalOffset + childIdx++, t_parentConstraints.cells, MAX_GEN_BOARDS);
        t_parentConstraints.revertConstraints(nValue, idx);
    }
}


