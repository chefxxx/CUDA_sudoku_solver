//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_BOARD_H
#define CUDA_SUDOKU_BOARD_H

#include <array>
#include <cstdint>
#include <string>
#include <tuple>
#include <vector>

constexpr int SUDOKU_BITPACK_N = 11;
constexpr int SUDOKU_SIZE      = 9;
using CELL_TYPE                = uint32_t;
constexpr int CELL_BITS_SZ     = sizeof(CELL_TYPE) * 8;
constexpr int CELL_BITS_LOG2   = 5;
constexpr int OFFSET_BITS_SZ   = 4;
constexpr int OFFSET_BITS_LOG2 = 2;

struct Board
{
    // TODO: change so constructor takes std::vector<CELL_TYPE>
    explicit Board(std::string_view t_line);
    void                    setValue(int t_idx, CELL_TYPE t_num);
    void                    printBoard() const;
    [[nodiscard]] CELL_TYPE getValue(int t_idx) const;

private:
    std::array<CELL_TYPE, SUDOKU_BITPACK_N> m_inside{0};
};

// TODO: add validness flag to detect invalid boards
struct BoardConstraints
{
    uint16_t squares[SUDOKU_SIZE];
    uint16_t rows[SUDOKU_SIZE];
    uint16_t cols[SUDOKU_SIZE];

    bool isValid = true;

    explicit BoardConstraints(const std::vector<CELL_TYPE> &t_numbers);
    [[nodiscard]] static std::tuple<int, int, int> getConstraintsIndexes(int t_BoardIdx);
};


#endif // CUDA_SUDOKU_BOARD_H
