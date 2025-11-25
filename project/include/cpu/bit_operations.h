//
// Created by chefxx on 14.11.2025.
//

#ifndef SUDOKU_BIT_OPERATIONS_H
#define SUDOKU_BIT_OPERATIONS_H

#include "board_defines.h"

constexpr CONSTRAINTS_TYPE MIN_LSB = 1u;

// this func is used for setting bits
inline void setBitAtIdx(CONSTRAINTS_TYPE &a, const uint32_t idx) { a |= MIN_LSB << idx; }

// this func is used for checking bits
inline bool checkBitAtIdx(const CONSTRAINTS_TYPE a, const uint32_t idx) { return a & (MIN_LSB << idx); }

#endif // SUDOKU_BIT_OPERATIONS_H
