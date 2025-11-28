//
// Created by chefxx on 14.11.2025.
//

#ifndef SUDOKU_BIT_OPERATIONS_H
#define SUDOKU_BIT_OPERATIONS_H

#include "board_defines.h"

constexpr CONSTRAINTS_TYPE MIN_LSB = 1u;

// this func is used for setting bits
__device__ __host__ __forceinline__ void setBitAtIdx(CONSTRAINTS_TYPE &a, const uint32_t idx) { a |= MIN_LSB << idx; }

// this func is used for checking bits
__device__ __host__ __forceinline__ bool checkBitAtIdx(const CONSTRAINTS_TYPE a, const uint32_t idx) { return a & (MIN_LSB << idx); }

#endif // SUDOKU_BIT_OPERATIONS_H
