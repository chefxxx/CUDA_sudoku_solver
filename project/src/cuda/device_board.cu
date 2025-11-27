//
// Created by chefxx on 26.11.2025.
//

#include "board_infra.cuh"
#include "device_board.cuh"
#include "solver_infra.cuh"

__device__ void DeviceBoard::setValue(const int t_idx, const CELL_TYPE t_num) { setValueInfra(cells, t_idx, t_num); }

__device__ CELL_TYPE DeviceBoard::getValue(const int t_idx) const { return getValueInfra(cells, t_idx); }

__device__ __forceinline__ void
DeviceBoard::initBoard(const size_t t_workId, const CELL_TYPE *t_boardsBuff, const size_t t_stride)
{
#pragma unroll
    for (size_t k = 0; k < SUDOKU_BITPACK_N; ++k) {
        cells[k] = t_boardsBuff[t_workId + k * t_stride];
    }
}

__device__ __forceinline__ void DeviceConstraints::initConstraints(const size_t            t_workId,
                                                                   const CONSTRAINTS_TYPE *t_constraintsBuff,
                                                                   const size_t            t_stride)
{
#pragma unroll
    for (int i = 0; i < CONSTRAINTS_N; ++i) {
#pragma unroll
        for (size_t k = 0; k < SUDOKU_SIZE; ++k) {
            cells[i][k] = t_constraintsBuff[t_workId + i * t_stride * SUDOKU_SIZE + k * t_stride];
        }
    }
}

__device__ __forceinline__ ConstraintsCoordinates DeviceConstraints::getConstraintsIndexes(int t_boardIdx)
{
    return getConstraintsIndexesInfra(t_boardIdx);
}