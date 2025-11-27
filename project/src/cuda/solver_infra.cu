//
// Created by chefxx on 13.11.2025.
//

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

__host__ std::tuple<std::vector<CELL_TYPE>, std::vector<uint16_t>, int>
         convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards)
{
    int                    globalIdx = 0;
    std::vector<CELL_TYPE> globalBoards(MAX_GEN_BOARDS * SUDOKU_BITPACK_N, 0);
    std::vector<uint16_t>  globalConstraints(MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE, 0);

    for (const auto &board : t_encodedBoards) {
        const auto values = convertLineToNumbers(board);
        if (values.has_value()) {
            const BoardConstraints tmpC(values.value());
            if (!tmpC.isValid) {
                myLog::warn("Not valid board found!");
            }
            else {
                // save constraints to buffer
                saveConstraintsToBuffer(
                    globalConstraints.data(), MAX_GEN_BOARDS * SUDOKU_SIZE, globalIdx, tmpC, MAX_GEN_BOARDS);

                // create board and save it to buffer
                createAndSaveBoardToBuffer(globalBoards.data(), globalIdx, values.value(), MAX_GEN_BOARDS);
                globalIdx++;
            }
        }
    }
    return std::make_tuple(globalBoards, globalConstraints, globalIdx);
}

void saveConstraintsToBuffer(uint16_t               *t_buff,
                             const size_t            t_constraintOffset,
                             const size_t            t_globalIdx,
                             const BoardConstraints &t_currConstraints,
                             const size_t            t_stride)
{
    for (int i = 0; i < CONSTRAINTS_N; ++i) {
        for (int k = 0; k < SUDOKU_SIZE; ++k) {
            t_buff[t_globalIdx + i * t_constraintOffset + k * t_stride] = t_currConstraints.constraints[i][k];
        }
    }
}

void createAndSaveBoardToBuffer(CELL_TYPE                    *t_buff,
                                const size_t                  t_globalIdx,
                                const std::vector<CELL_TYPE> &t_values,
                                const size_t                  t_stride)
{
    const Board tmpB(t_values);
    for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
        t_buff[t_globalIdx + i * t_stride] = tmpB.inside[i];
    }
}