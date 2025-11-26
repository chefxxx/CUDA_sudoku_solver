//
// Created by chefxx on 26.11.2025.
//

#ifndef SUDOKU_DEVICE_BOARD_CUH
#define SUDOKU_DEVICE_BOARD_CUH

#include "board_infra.cuh"

struct DeviceBoard
{
    DeviceBoard() = default;
    __device__ void                    setValue(int t_idx, CELL_TYPE t_num);
    __device__ [[nodiscard]] CELL_TYPE getValue(int t_idx) const;
    CELL_TYPE                          cells[SUDOKU_BITPACK_N];
};

struct DeviceConstraints
{
    CONSTRAINTS_TYPE                         cells[CONSTRAINTS_N][SUDOKU_SIZE];
    __device__ static ConstraintsCoordinates getConstraintsIndexes(int t_boardIdx);
};


#endif
