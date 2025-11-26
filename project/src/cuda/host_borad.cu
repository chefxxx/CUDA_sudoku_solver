//
// Created by chefxx on 13.11.2025.
//

#include <iostream>

#include "host_board.cuh"
#include "bit_operations.h"
#include "board_infra.cuh"

Board::Board(const std::vector<CELL_TYPE> &t_numbers)
{
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        setValue(i, t_numbers[i]);
    }
}

void Board::setValue(const int t_idx, const CELL_TYPE t_num)
{
    setValueInfra(inside.data(), t_idx, t_num);
}

CELL_TYPE Board::getValue(const int t_idx) const
{
    return getValueInfra(inside.data(), t_idx);
}

void Board::printBoard() const
{
    constexpr std::string_view row = "+-------+-------+-------+\n";
    std::cout << row;
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
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

BoardConstraints::BoardConstraints(const std::vector<CELL_TYPE> &t_numbers)
{
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        const auto num                   = t_numbers[i];
        auto [rowIdx, colIdx, squareIdx] = getConstraintsIndexes(i);
        if (num > 0) {
            if (checkBitAtIdx(constraints[row][rowIdx], num) || checkBitAtIdx(constraints[col][colIdx], num)
                || checkBitAtIdx(constraints[square][squareIdx], num))
                isValid = false;
            setBitAtIdx(constraints[row][rowIdx], num);
            setBitAtIdx(constraints[col][colIdx], num);
            setBitAtIdx(constraints[square][squareIdx], num);
        }
    }
}

std::tuple<int, int, int> BoardConstraints::getConstraintsIndexes(const int t_BoardIdx)
{
    const auto coords = getConstraintsIndexesInfra(t_BoardIdx);
    return std::make_tuple(coords.row, coords.col, coords.square);
}