//
// Created by chefxx on 14.11.2025.
//

#ifndef SUDOKU_BIT_OPERATIONS_H
#define SUDOKU_BIT_OPERATIONS_H

constexpr uint16_t MIN_LSB = 1u;

// this func is used for setting bits in constraints
inline void setBitAtIdx(uint16_t &a, const uint32_t idx) { a |= MIN_LSB << idx; }

#endif // SUDOKU_BIT_OPERATIONS_H
