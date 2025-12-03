//
// Created by chefxx on 25.11.2025.
//

#ifndef CUDA_SUDOKU_GENERATE_BOARDS_H
#define CUDA_SUDOKU_GENERATE_BOARDS_H

#include <cstdint>

#include "board_infra.cuh"
#include "device_board.cuh"
#include "solver_infra.cuh"

constexpr int THREADS_PER_BLOCK = 1;
constexpr int BLOCKS_PER_GRID   = 1;
constexpr int MAX_GEN_BOARDS    = 1048576;
constexpr int MAX_GENERATIONS   = 10;

__global__ void createChildren(const CELL_TYPE        *t_inBoardsBuff,
                               CELL_TYPE              *t_outBoardsBuff,
                               const CONSTRAINTS_TYPE *t_inConstraintsBuff,
                               CONSTRAINTS_TYPE       *t_outConstraintsBuff,
                               const uint32_t         *t_inRootsBuff,
                               uint32_t               *t_outRootsBuff,
                               const uint32_t         *t_offsetBuff,
                               const uint16_t         *t_cellNumsBuff,
                               size_t                  t_boardCount);

__global__ void chooseChildren(const CELL_TYPE        *t_boardsBuff,
                               const CONSTRAINTS_TYPE *t_constraintsBuff,
                               uint32_t               *t_childrenBuff,
                               uint16_t               *t_cellNumsBuff,
                               size_t                  t_boardCount);

__device__ void findMostConstrainedCell(const DeviceBoard       &t_board,
                                        const DeviceConstraints &t_constraints,
                                        uint16_t                &t_cellIdx,
                                        uint16_t                &t_minChildNum);

__device__ __forceinline__ void createAndAlignInBuff(CELL_TYPE         *t_outBoardsBuff,
                                                     CONSTRAINTS_TYPE  *t_outConstraintsBuff,
                                                     uint32_t          *t_outRootsBuff,
                                                     const uint32_t    &t_globalOffset,
                                                     const uint32_t    &t_rootNum,
                                                     const uint16_t    &t_cellNum,
                                                     DeviceBoard       &t_parentBoard,
                                                     DeviceConstraints &t_parentConstraints)
{
    const auto       idx  = getConstraintsIndexesInfra(t_cellNum);
    CONSTRAINTS_TYPE mask = t_parentConstraints.cells[row][idx.row] & t_parentConstraints.cells[col][idx.col]
                          & t_parentConstraints.cells[square][idx.square];
    uint32_t childIdx = 0;
    while (mask) {
        const int nValue = popLsb(mask);
        t_parentConstraints.updateConstraints(nValue, idx);
        t_parentBoard.setValue(t_cellNum, nValue);
        saveBoardToBuffer(t_outBoardsBuff, t_globalOffset + childIdx, t_parentBoard.cells, MAX_GEN_BOARDS);
        t_outRootsBuff[t_globalOffset + childIdx] = t_rootNum;
        saveConstraintsToBuffer(t_outConstraintsBuff,
                                MAX_GEN_BOARDS * SUDOKU_SIZE,
                                t_globalOffset + childIdx++,
                                t_parentConstraints.cells,
                                MAX_GEN_BOARDS);
        t_parentConstraints.revertConstraints(nValue, idx);
    }
}

#endif
