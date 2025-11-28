//
// Created by chefxx on 25.11.2025.
//

#ifndef CUDA_SUDOKU_GENERATE_BOARDS_H
#define CUDA_SUDOKU_GENERATE_BOARDS_H

#include <cstdint>

#include "board_infra.cuh"
#include "device_board.cuh"

constexpr int THREADS_PER_BLOCK = 128;
constexpr int BLOCKS_PER_GRID   = 128;
constexpr int MAX_GEN_BOARDS    = 1048576;
constexpr int MAX_GENERATIONS   = 1;

__global__ void createChildren(const CELL_TYPE        *t_inBoardsBuff,
                               const CELL_TYPE        *t_outBoardsBuff,
                               const CONSTRAINTS_TYPE *t_inConstraintsBuff,
                               const CONSTRAINTS_TYPE *t_outConstraintsBuff,
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
__device__ void createAndAlignInBuff(const CELL_TYPE         *t_outBoardsBuff,
                                     const CONSTRAINTS_TYPE  *t_outConstraintsBuff,
                                     uint32_t                 t_globalOffset,
                                     uint16_t                 t_cellNum,
                                     const DeviceBoard       &t_parentBoard,
                                     const DeviceConstraints &t_parentConstraints);

#endif
