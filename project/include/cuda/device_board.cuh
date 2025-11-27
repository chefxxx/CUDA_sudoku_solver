//
// Created by chefxx on 26.11.2025.
//

#ifndef SUDOKU_DEVICE_BOARD_CUH
#define SUDOKU_DEVICE_BOARD_CUH

#include <iostream>
#include "board_infra.cuh"

struct DeviceBoard
{
    __device__ DeviceBoard() = default;
    __device__ __forceinline__ void setValue(const int t_idx, CELL_TYPE const t_num)
    {
        setValueInfra(cells, t_idx, t_num);
    }
    [[nodiscard]] __device__ __forceinline__ CELL_TYPE getValue(const int t_idx) const
    {
        return getValueInfra(cells, t_idx);
    }
    __device__ __forceinline__ void initBoard(const size_t t_workId, const CELL_TYPE *t_boardsBuff, const size_t t_stride)
    {
        printf("\nGPU\n");
#pragma unroll
        for (size_t k = 0; k < SUDOKU_BITPACK_N; ++k) {
            cells[k] = t_boardsBuff[t_workId + k * t_stride];
            printf("%d\n", cells[k]);
        }
    }
    CELL_TYPE                       cells[SUDOKU_BITPACK_N];
};

struct DeviceConstraints
{
    __device__ DeviceConstraints() = default;
    __device__ __forceinline__ static
    ConstraintsCoordinates getConstraintsIndexes(const int t_boardIdx)
    {
        return getConstraintsIndexesInfra(t_boardIdx);
    }
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
    CONSTRAINTS_TYPE cells[CONSTRAINTS_N][SUDOKU_SIZE];
};


#endif
