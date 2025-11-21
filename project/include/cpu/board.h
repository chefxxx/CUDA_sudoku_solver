//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_BOARD_H
#define CUDA_SUDOKU_BOARD_H

#include <array>
#include <cstdint>
#include <tuple>
#include <vector>

constexpr int SUDOKU_BITPACK_N = 11;
constexpr int SUDOKU_SIZE      = 9;
constexpr int SUDOKU_OFFSET    = 81;
using CELL_TYPE                = uint32_t;
constexpr int CELL_BITS_SZ     = sizeof(CELL_TYPE) * 8;
constexpr int CELL_BITS_LOG2   = 5;
constexpr int OFFSET_BITS_SZ   = 4;
constexpr int OFFSET_BITS_LOG2 = 2;

struct Board
{
    explicit Board(const std::vector<CELL_TYPE> &t_numbers);
    void                    setValue(int t_idx, CELL_TYPE t_num);
    void                    printBoard() const;
    [[nodiscard]] CELL_TYPE getValue(int t_idx) const;

    std::array<CELL_TYPE, SUDOKU_BITPACK_N> inside{};
};

constexpr int CONSTRAINTS_N = 3;

enum constraints_indexes {
    row    = 0,
    col    = 1,
    square = 2,
};

struct BoardConstraints
{
    std::array<std::array<uint16_t, SUDOKU_SIZE>, 3> constraints{{{}, {}, {}}};

    bool isValid = true;

    explicit BoardConstraints(const std::vector<CELL_TYPE> &t_numbers);
    [[nodiscard]] static std::tuple<int, int, int> getConstraintsIndexes(int t_BoardIdx);
};


#endif // CUDA_SUDOKU_BOARD_H
