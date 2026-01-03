//
// Created by chefxx on 14.11.2025.
//

#ifndef SUDOKU_BIT_OPERATIONS_H
#define SUDOKU_BIT_OPERATIONS_H

#include "defines.h"
#include <bit>

constexpr CONSTRAINTS_TYPE MIN_LSB = 1u;

// this func is used for setting bits
__device__ __host__ __forceinline__ void setBitAtIdx(CONSTRAINTS_TYPE &a, const uint32_t idx) { a |= MIN_LSB << idx; }

// this func is used for checking bits
__device__ __host__ __forceinline__ bool checkBitAtIdx(const CONSTRAINTS_TYPE a, const uint32_t idx)
{
    return a & (MIN_LSB << idx);
}

// this func sets to 0 bit of given idx
__device__ __host__ __forceinline__ void resetBitAtIdx(CONSTRAINTS_TYPE &a, const uint32_t idx)
{
    a &= ~(MIN_LSB << idx);
}

// this func returns number of 1's
__device__ __host__ __forceinline__ int popCount(const CONSTRAINTS_TYPE a)
{
#if defined(__CUDA_ARCH__)
    return __popc(a);
#else
    return std::popcount(a);
#endif
}

// this func returns index of lsb index, 0-based
__device__ __host__ __forceinline__ int getLsb(const CONSTRAINTS_TYPE a)
{
#if defined(__CUDA_ARCH__)
    return __ffs(a) - 1; //__ffs() is 1-based, so - 1
#else
    return std::countr_zero(a);
#endif
}

// retrieves lsb index and resets lsb
__device__ __host__ __forceinline__ int popLsb(CONSTRAINTS_TYPE &a)
{
    const int idx = getLsb(a);
    a &= a - 1;
    return idx;
}

#endif // SUDOKU_BIT_OPERATIONS_H
