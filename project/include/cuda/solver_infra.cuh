//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_SOLVER_H
#define CUDA_SUDOKU_SOLVER_H

#include <optional>
#include <string>
#include <vector>

#include "../cpu/host_board.h"
#include "board_infra.cuh"

__host__ std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(std::string_view t_line);
__host__ std::tuple<std::vector<CELL_TYPE>, std::vector<CONSTRAINTS_TYPE>, int, int>
         convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards, size_t t_stride);

__device__ __host__ __forceinline__ void saveConstraintsToBuffer(CONSTRAINTS_TYPE *t_buff,
                                                                 const size_t      t_constraintOffset,
                                                                 const size_t      t_globalIdx,
                                                                 CONSTRAINTS_TYPE  t_currConstraints[][SUDOKU_SIZE],
                                                                 const size_t      t_stride)
{
    for (int i = 0; i < CONSTRAINTS_N; ++i) {
        for (int k = 0; k < SUDOKU_SIZE; ++k) {
            t_buff[t_globalIdx + i * t_constraintOffset + k * t_stride] = t_currConstraints[i][k];
        }
    }
}

__device__ __host__ __forceinline__ void
saveBoardToBuffer(CELL_TYPE *t_buff, const size_t t_globalIdx, const CELL_TYPE *t_values, const size_t t_stride)
{
    for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
        t_buff[t_globalIdx + i * t_stride] = t_values[i];
    }
}


__host__ std::tuple<std::vector<Board>, std::vector<BoardConstraints>> createCPU(const std::vector<std::string> &t_encodedBoards);
__host__ int countEmptyCPU(const Board &t_board);

#endif // CUDA_SUDOKU_SOLVER_H
