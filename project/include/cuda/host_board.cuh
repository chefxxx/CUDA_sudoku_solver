//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_BOARD_H
#define CUDA_SUDOKU_BOARD_H

#include <array>
#include <cstdint>
#include <tuple>
#include <vector>

#include "board_infra.cuh"

struct Board
{
    Board() = default;
    explicit Board(const std::vector<CELL_TYPE> &t_numbers);
    void                    setValue(int t_idx, CELL_TYPE t_num);
    void                    printBoard() const;
    [[nodiscard]] CELL_TYPE getValue(int t_idx) const;
    void initBoard(size_t t_globalIdx, const std::vector<CELL_TYPE> &t_boardsBuff, size_t t_stride);
    std::array<CELL_TYPE, SUDOKU_BITPACK_N> inside{};
};

struct BoardConstraints
{
    std::array<std::array<CONSTRAINTS_TYPE, SUDOKU_SIZE>, 3> constraints{{{}, {}, {}}};

    bool isValid = true;
    explicit BoardConstraints(const std::vector<CELL_TYPE> &t_numbers);
    [[nodiscard]] static std::tuple<int, int, int> getConstraintsIndexes(int t_BoardIdx);
};


#endif // CUDA_SUDOKU_BOARD_H
