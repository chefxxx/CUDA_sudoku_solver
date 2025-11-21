//
// Created by chefxx on 13.11.2025.
//

#include "solver_infra.h"
#include "spdlog_macros.h"

std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(const std::string_view t_line)
{
    std::vector<CELL_TYPE> numbers;
    for (const auto &c : t_line) {
        const auto num = c - '0';
        if (num < 0 || num > 9) {
            myLog::warn("Not valid character found!");
            return std::nullopt;
        }
        numbers.emplace_back(num);
    }
    return std::make_optional(numbers);
}

std::tuple<std::vector<CELL_TYPE>, std::vector<uint16_t>, int> convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards)
{
    int globalIdx = 0;
    std::vector<CELL_TYPE> globalBoards(SUDOKU_BITPACK_N * t_encodedBoards.size(), 0);
    std::vector<uint16_t> globalConstraints(3 * SUDOKU_SIZE * t_encodedBoards.size(), 0);

    for (const auto& board : t_encodedBoards) {
        const auto values = convertLineToNumbers(board);
        if (values.has_value()) {
            const BoardConstraints tmpC(values.value());
            if (!tmpC.isValid) {
                myLog::warn("Not valid board found!");
            }
            else {
                // save constraints to buffer

                // create board and save it to buffer
                const Board tmpB(values.value());
                for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
                    globalBoards[globalIdx + i * t_encodedBoards.size()] = tmpB.inside[i];
                }
                globalIdx++;
            }
        }
    }
    return std::make_tuple(globalBoards, globalConstraints, globalIdx);
}