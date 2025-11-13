//
// Created by chefxx on 13.11.2025.
//

#include "board.h"

Board::Board(const std::string &t_line)
{
    assert(t_line.size() == SUDOKU_9 * SUDOKU_9);
    for (size_t i = 0; i < t_line.size(); i += SUDOKU_9) {
        auto row = t_line.substr(i, SUDOKU_9);

    }
}