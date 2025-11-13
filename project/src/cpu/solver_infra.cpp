//
// Created by chefxx on 13.11.2025.
//

#include "solver_infra.h"

std::vector<Board> createBoardsSerial(const std::vector<std::string>& t_encodedBoards)
{
    std::vector<Board> boards;
    for (const auto& line: t_encodedBoards) {
        boards.emplace_back(line);
    }
    return boards;
}