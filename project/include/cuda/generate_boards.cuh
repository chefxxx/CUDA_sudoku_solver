//
// Created by chefxx on 25.11.2025.
//

#ifndef CUDA_SUDOKU_GENERATE_BOARDS_H
#define CUDA_SUDOKU_GENERATE_BOARDS_H

#include <cstdint>

#include "board_infra.cuh"
#include "device_board.cuh"

__global__ void createChildren();
__global__ void chooseChildren(const CELL_TYPE        *t_boardsBuff,
                               const CONSTRAINTS_TYPE *t_constraintsBuff,
                               uint16_t               *t_childrenBuff,
                               const int              *t_boardCount);

__device__ __forceinline__ void storeDeviceConstraints(size_t                  t_workId,
                                                       const CONSTRAINTS_TYPE *t_constraintsBuff,
                                                       DeviceConstraints      *t_sharedConstraintsBuff,
                                                       size_t                  t_tid);

__device__ __forceinline__ [[nodiscard]] uint16_t findMostConstrainedCell(const DeviceBoard       &t_board,
                                                                          const DeviceConstraints &t_constraints);

#endif
