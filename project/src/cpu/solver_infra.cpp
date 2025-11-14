//
// Created by chefxx on 13.11.2025.
//

#include "solver_infra.h"

#include <spdlog/spdlog.h>

std::vector<BoardConstraints> createBoardsConstraintsSerial(const std::vector<std::string> &t_encodedBoards)
{
    std::vector<BoardConstraints> boards;
    for (const auto &line : t_encodedBoards) {
        const std::string boardLine = line.substr(0, line.find(' '));
        const std::string encoded   = line.substr(line.find(' ') + 1);
        const auto        numbers   = convertLineToNumbers(encoded, boardLine);
        if (numbers.has_value()) {
            const BoardConstraints constraints{numbers.value()};
            if (!constraints.isValid)
                spdlog::error(
                    "createBoardsConstraintsSerial() - Invalid board detected in the line {}, repeated numbers!",
                    boardLine);
            else
                boards.push_back(constraints);
        }
    }
    return boards;
}

std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(const std::string_view t_line,
                                                           const std::string_view t_lineNumber)
{
    std::vector<CELL_TYPE> numbers;
    for (const auto &c : t_line) {
        const auto num = c - '0';
        if (num < 0 || num > 9) {
            spdlog::error("convertLineToNumbers() - Not valid character in the line {}!", t_lineNumber);
            return std::nullopt;
        }
        numbers.emplace_back(num);
    }
    return std::make_optional(numbers);
}