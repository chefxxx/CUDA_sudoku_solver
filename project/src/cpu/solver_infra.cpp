//
// Created by chefxx on 13.11.2025.
//

#include <cassert>
#include <iostream>
#include "solver_infra.h"

std::vector<BoardConstraints> createBoardsConstraintsSerial(const std::vector<std::string> &t_encodedBoards)
{
    std::vector<BoardConstraints> boards;
    for (const auto &line : t_encodedBoards) {
        const auto numbers = convertLineToNumbers(line);
        if (numbers.has_value()) {
            boards.emplace_back(numbers.value());
        }
    }
    return boards;
}

std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(const std::string_view t_line) {
    std::vector<CELL_TYPE> numbers;
    for (const auto &c : t_line) {
        const auto num = static_cast<CELL_TYPE>(c - '0');
        if (num > 9) {
            std::cerr << "ERROR: convertLineToNumbers() - Line contains unknown character!\n";
            return std::nullopt;
        }
        numbers.emplace_back(num);
    }
    return std::make_optional(numbers);
}