//
// Created by chefxx on 25.11.2025.
//

#ifndef SUDOKU_BOARD_DEFINES_H
#define SUDOKU_BOARD_DEFINES_H

#include <cstdint>

// ----------
// Used types
// ----------
using CELL_TYPE        = uint32_t;
using CONSTRAINTS_TYPE = uint16_t;

// --------------------------------
// Constants for board manipulation
// --------------------------------
constexpr int SUDOKU_BITPACK_N = 11;
constexpr int SUDOKU_SIZE      = 9;
constexpr int SUDOKU_OFFSET    = 81;
constexpr int CELL_BITS_SZ     = sizeof(CELL_TYPE) * 8;
constexpr int CELL_BITS_LOG2   = 5;
constexpr int OFFSET_BITS_SZ   = 4;
constexpr int OFFSET_BITS_LOG2 = 2;
constexpr int CONSTRAINTS_N    = 3;

#endif // SUDOKU_BOARD_DEFINES_H
