//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_BOARD_H
#define CUDA_SUDOKU_BOARD_H

#include <array>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <string>

constexpr size_t N_9 = 6;
constexpr size_t N_16 = 16;
constexpr size_t PUZZLE_9 = 9;
constexpr size_t PUZZLE_16 = 16;

template <size_t N>
concept sudoku_board_size = N == PUZZLE_9 || N == PUZZLE_16;

template <size_t PuzzleSize> requires sudoku_board_size<PuzzleSize>
struct Board
{
    explicit Board(const std::string& t_line);

private:
    static constexpr size_t N_INSIDE = PuzzleSize == PUZZLE_9 ? N_9 : N_16;
    std::array<__uint64_t, N_INSIDE>  m_inside;
};

template <size_t PuzzleSize> requires sudoku_board_size<PuzzleSize> Board<PuzzleSize>::Board(const std::string &t_line)
{
    assert(t_line.size() == PuzzleSize * PuzzleSize);
    for (size_t i = 0; i < t_line.size(); i += PuzzleSize) {
        auto row = t_line.substr(i, PuzzleSize);
        std::cout << row << "\n";
    }
}

#endif // CUDA_SUDOKU_BOARD_H
