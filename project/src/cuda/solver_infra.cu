//
// Created by chefxx on 13.11.2025.
//

#include <iostream>
#include <optional>

#include "board_infra.cuh"
#include "solver_infra.cuh"
#include "spdlog_macros.h"

__host__ std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(const std::string_view t_line)
{
    std::vector<CELL_TYPE> numbers;
    // t_line has '\n' at the end, so we loop over first 81 elements
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        const auto c   = t_line[i];
        const auto num = c - '0';
        if (num < 0 || num > 9) {
            myLog::warn(fmt::format("Not valid character {} found!", num));
            return std::nullopt;
        }
        numbers.emplace_back(num);
    }
    return std::make_optional(numbers);
}

__host__ std::tuple<std::vector<CELL_TYPE>, std::vector<CONSTRAINTS_TYPE>, int>
         convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards, const size_t t_stride)
{
    int                           globalIdx = 0;
    std::vector<CELL_TYPE>        globalBoards(t_stride * SUDOKU_BITPACK_N, 0);
    std::vector<CONSTRAINTS_TYPE> globalConstraints(t_stride * CONSTRAINTS_N * SUDOKU_SIZE, 0);

    for (const auto &board : t_encodedBoards) {
        const auto values = convertLineToNumbers(board);
        if (values.has_value()) {
            BoardConstraints tmpC(values.value());
            if (!tmpC.isValid) {
                myLog::warn("Not valid board found!");
            }
            else {
                // save constraints to buffer
                saveConstraintsToBuffer(globalConstraints.data(), t_stride * SUDOKU_SIZE, globalIdx, reinterpret_cast<CONSTRAINTS_TYPE (*)[SUDOKU_SIZE]>(tmpC.constraints.data()), t_stride);

                // create board and save it to buffer
                const Board tmpB(values.value());
                saveBoardToBuffer(globalBoards.data(), globalIdx, tmpB.inside.data(), t_stride);
                globalIdx++;
            }
        }
    }
    return std::make_tuple(globalBoards, globalConstraints, globalIdx);
}

__device__ __host__ void saveConstraintsToBuffer(CONSTRAINTS_TYPE *t_buff,
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

__device__ __host__ void saveBoardToBuffer(CELL_TYPE *t_buff, const size_t t_globalIdx, const CELL_TYPE *t_values, const size_t t_stride)
{
    for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
        t_buff[t_globalIdx + i * t_stride] = t_values[i];
    }
}