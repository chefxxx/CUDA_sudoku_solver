//
// Created by chefxx on 13.11.2025.
//

#include <bitset>
#include <iostream>

#include "board.h"

Board::Board(const std::string_view t_line)
{
    assert(t_line.size() == SUDOKU_9 * SUDOKU_9);
    int idx = 0;
    for (size_t i = 0; i < t_line.size(); i += SUDOKU_9) {
        const auto row = t_line.substr(i, SUDOKU_9);
        for (const auto& c : row) {
            const auto num = static_cast<CELL_SZ>(c - '0');
            assert(num <= 9);
            setValue(idx, num);
            idx++;
        }
    }
}

void Board::setValue(const int t_idx, const CELL_SZ t_num)
{
    const int offset = t_idx << 2;
    const int arrayIdx = offset >> 5;
    const int inArrayOffset = offset % 32;
    const CELL_SZ mask = t_num << inArrayOffset;
    m_inside[arrayIdx] |= mask;
}