//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_BOARD_H
#define CUDA_SUDOKU_BOARD_H

#include <array>
#include <cstdint>
#include <string>

constexpr int SUDOKU_BITPACK_N = 11;
constexpr int SUDOKU_SIZE      = 9;
using CELL_TYPE                = uint32_t;
constexpr int CELL_BITS_SZ     = sizeof(CELL_TYPE) * 8;
constexpr int CELL_BITS_LOG2   = 5;
constexpr int OFFSET_BITS_SZ   = 4;
constexpr int OFFSET_BITS_LOG2 = 2;

struct Board
{
    explicit Board(std::string_view t_line);
    void    setValue(int t_idx, CELL_TYPE t_num);
    void    printBoard() const;
    CELL_TYPE getValue(int t_idx) const;

private:
    std::array<CELL_TYPE, SUDOKU_BITPACK_N> m_inside{0};
};

struct BoardConstraints
{
    short squares[SUDOKU_SIZE];
    short rows[SUDOKU_SIZE];
    short cols[SUDOKU_SIZE];
};


#endif // CUDA_SUDOKU_BOARD_H
