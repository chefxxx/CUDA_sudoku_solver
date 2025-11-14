//
// Created by chefxx on 13.11.2025.
//

#include <iostream>

#include "board.h"

Board::Board(const std::string_view t_line)
{
    int idx = 0;
    for (size_t i = 0; i < t_line.size(); i += SUDOKU_SIZE) {
        const auto row = t_line.substr(i, SUDOKU_SIZE);
        for (const auto &c : row) {
            const auto num = static_cast<CELL_TYPE>(c - '0');
            setValue(idx, num);
            idx++;
        }
    }
}

void Board::setValue(const int t_idx, const CELL_TYPE t_num)
{
    const int     offset        = t_idx << OFFSET_BITS_LOG2;
    const int     arrayIdx      = offset >> CELL_BITS_LOG2;
    const int     inArrayOffset = offset % CELL_BITS_LOG2;
    const CELL_TYPE mask        = t_num << inArrayOffset;
    m_inside[arrayIdx] |= mask;
}

CELL_TYPE Board::getValue(const int t_idx) const
{
    const int offset        = t_idx << OFFSET_BITS_LOG2;
    const int arrayIdx      = offset >> CELL_BITS_LOG2;
    const int inArrayOffset = offset % CELL_BITS_SZ;
    CELL_TYPE   value       = m_inside[arrayIdx];
    value                   = value >> inArrayOffset & 0xF;
    return value;
}

void Board::printBoard() const
{
    constexpr std::string_view row = "+-------+-------+-------+\n";
    std::cout << row;
    for (int i = 0; i < 81; ++i) {
        if (i % 9 == 0)
            std::cout << '|';
        const auto value = getValue(i);
        std::cout << ' ';
        value == 0 ? std::cout << '.' : std::cout << value;
        if (i % 9 == 2 || i % 9 == 5)
            std::cout << " |";
        if ((i + 1) % 9 == 0)
            std::cout << " |\n";
        if ((i + 1) % 27 == 0)
            std::cout << row;
    }
}