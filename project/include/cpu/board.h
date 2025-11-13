//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_BOARD_H
#define CUDA_SUDOKU_BOARD_H

#include <array>
#include <cstdint>
#include <string>

constexpr size_t SUDOKU_9_N = 6;
constexpr size_t SUDOKU_9 = 9;

struct Board
{
    explicit Board(const std::string& t_line);
private:
    std::array<uint64_t, SUDOKU_9_N>  m_inside{ 0 };
};



#endif // CUDA_SUDOKU_BOARD_H
