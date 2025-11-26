//
// Created by chefxx on 13.11.2025.
//

#include <optional>

#include "solver_infra.cuh"
#include "board_infra.cuh"
#include "spdlog_macros.h"

std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(const std::string_view t_line)
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

std::tuple<std::vector<CELL_TYPE>, std::vector<uint16_t>, int>
convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards)
{
    int                    globalIdx = 0;
    std::vector<CELL_TYPE> globalBoards(MAX_GEN_BOARDS * SUDOKU_BITPACK_N , 0);
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
                constexpr size_t offset = MAX_GEN_BOARDS * SUDOKU_SIZE;
                saveConstraintsToBuffer(globalConstraints.data(), offset, globalIdx, tmpC);

                // create board and save it to buffer
                createAndSaveBoardToBuffer(globalBoards.data(), globalIdx, values.value());
                globalIdx++;
            }
        }
    }
    return std::make_tuple(globalBoards, globalConstraints, globalIdx);
}

void saveConstraintsToBuffer(uint16_t               *t_buff,
                             const size_t            t_constraintOffset,
                             const size_t            t_globalIdx,
                             const BoardConstraints &t_currConstraints)
{
    for (int i = 0; i < CONSTRAINTS_N; ++i) {
        for (int k = 0; k < SUDOKU_SIZE; ++k) {
            t_buff[t_globalIdx + i * t_constraintOffset + k * MAX_GEN_BOARDS] = t_currConstraints.constraints[i][k];
        }
    }
}

void createAndSaveBoardToBuffer(CELL_TYPE                    *t_buff,
                                const size_t                  t_globalIdx,
                                const std::vector<CELL_TYPE> &t_values)
{
    const Board tmpB(t_values);
    for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
        t_buff[t_globalIdx + i * MAX_GEN_BOARDS] = tmpB.inside[i];
    }
}