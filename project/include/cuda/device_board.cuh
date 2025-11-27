//
// Created by chefxx on 26.11.2025.
//

#ifndef SUDOKU_DEVICE_BOARD_CUH
#define SUDOKU_DEVICE_BOARD_CUH

#include "board_infra.cuh"

struct DeviceBoard
{
    DeviceBoard() = default;
    __device__ __forceinline__ void                    setValue(int t_idx, CELL_TYPE t_num);
    __device__ __forceinline__ [[nodiscard]] CELL_TYPE getValue(int t_idx) const;
    __device__ __forceinline__ void                    initBoard(size_t t_workId, const CELL_TYPE *t_boardsBuff, size_t t_stride);
    CELL_TYPE                                          cells[SUDOKU_BITPACK_N];
};

struct DeviceConstraints
{
    DeviceConstraints() = default;
    __device__ __forceinline__ static ConstraintsCoordinates getConstraintsIndexes(int t_boardIdx);
    __device__ __forceinline__ void   initConstraints(size_t t_workId, const CONSTRAINTS_TYPE *t_constraintsBuff, size_t t_stride);
    CONSTRAINTS_TYPE                  cells[CONSTRAINTS_N][SUDOKU_SIZE];
};


#endif
