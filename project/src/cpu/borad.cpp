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

CELL_SZ Board::getValue(const int t_idx) const
{
    const int offset = t_idx << 2;
    const int arrayIdx = offset >> 5;
    const int inArrayOffset = offset % 32;
    CELL_SZ value = m_inside[arrayIdx];
    value = value >> inArrayOffset & 0xF;
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