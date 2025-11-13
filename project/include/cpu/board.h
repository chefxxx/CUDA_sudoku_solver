//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_BOARD_H
#define CUDA_SUDOKU_BOARD_H

#include <array>
#include <cstdint>
#include <string>
#include <cassert>

constexpr size_t SUDOKU_9_N      = 11;
constexpr size_t SUDOKU_9        = 9;
using     CELL_SZ                = uint32_t;

struct Board
{
    explicit Board(std::string_view t_line);
    void setValue(int t_idx, CELL_SZ t_num);
    CELL_SZ getValue(int t_idx) const;
    void printBoard() const;
private:
    std::array<CELL_SZ, SUDOKU_9_N>  m_inside{ 0 };
};



#endif // CUDA_SUDOKU_BOARD_H
