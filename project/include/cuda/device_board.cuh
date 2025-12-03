//
// Created by chefxx on 26.11.2025.
//

#ifndef SUDOKU_DEVICE_BOARD_CUH
#define SUDOKU_DEVICE_BOARD_CUH

#include <iostream>

#include "bit_operations.cuh"
#include "board_infra.cuh"

struct DeviceBoard
{
    __device__                      DeviceBoard() = default;
    __device__ __forceinline__ void setValue(const int t_idx, CELL_TYPE const t_num)
    {
        setValueInfra(cells, t_idx, t_num);
    }
    [[nodiscard]] __device__ __forceinline__ CELL_TYPE getValue(const int t_idx) const
    {
        return getValueInfra(cells, t_idx);
    }
    __device__ __forceinline__ void
    initBoard(const size_t t_workId, const CELL_TYPE *t_boardsBuff, const size_t t_stride)
    {
        loadBoardFromBuffer(cells, t_workId, t_boardsBuff, t_stride);
    }
    CELL_TYPE cells[SUDOKU_BITPACK_N];
};

struct DeviceConstraints
{
    __device__ DeviceConstraints() = default;
    __device__ __forceinline__ void
    initConstraints(const size_t t_workId, const CONSTRAINTS_TYPE *t_constraintsBuff, const size_t t_stride)
    {
#pragma unroll
        for (int i = 0; i < CONSTRAINTS_N; ++i) {
#pragma unroll
            for (size_t k = 0; k < SUDOKU_SIZE; ++k) {
                cells[i][k] = t_constraintsBuff[t_workId + i * t_stride * SUDOKU_SIZE + k * t_stride];
            }
        }
    }
    __device__ __forceinline__ void updateConstraints(const int t_value, const int &t_boardIdx)
    {
        const ConstraintsCoordinates coordinates = getConstraintsIndexesInfra(t_boardIdx);
        updateConstraints(t_value, coordinates);
    }
    __device__ __forceinline__ void updateConstraints(const int t_value, const ConstraintsCoordinates &t_idx)
    {
        resetBitAtIdx(cells[row][t_idx.row], t_value);
        resetBitAtIdx(cells[col][t_idx.col], t_value);
        resetBitAtIdx(cells[square][t_idx.square], t_value);
    }
    __device__ __forceinline__ void revertConstraints(const int t_value, const int &t_boardIdx)
    {
        const ConstraintsCoordinates coordinates = getConstraintsIndexesInfra(t_boardIdx);
        revertConstraints(t_value, coordinates);
    }
    __device__ __forceinline__ void revertConstraints(const int t_value, const ConstraintsCoordinates &t_idx)
    {
        setBitAtIdx(cells[row][t_idx.row], t_value);
        setBitAtIdx(cells[col][t_idx.col], t_value);
        setBitAtIdx(cells[square][t_idx.square], t_value);
    }
    __device__ __forceinline__ CONSTRAINTS_TYPE getConstraintsMask(const int t_boardIdx) const
    {
        const ConstraintsCoordinates coordinates = getConstraintsIndexesInfra(t_boardIdx);
        return cells[row][coordinates.row] & cells[col][coordinates.col] & cells[square][coordinates.square];
    }

    CONSTRAINTS_TYPE cells[CONSTRAINTS_N][SUDOKU_SIZE];
};


#endif
