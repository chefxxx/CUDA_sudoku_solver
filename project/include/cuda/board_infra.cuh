//
// Created by chefxx on 25.11.2025.
//

#ifndef SUDOKU_BOARD_INFRA_H
#define SUDOKU_BOARD_INFRA_H

#include "board_defines.h"

// -----------------------------
// Simple struct for constraints
// -----------------------------
struct ConstraintsCoordinates
{
    __device__ __host__ ConstraintsCoordinates(const int t_row, const int t_col, const int t_square) : row(t_row), col(t_col), square(t_square) {}
    int row;
    int col;
    int square;
};

// ---------------------------
// Simple enum for constraints
// ---------------------------
enum constraints_indexes {
    row    = 0,
    col    = 1,
    square = 2,
};

// ---------
// Functions
// ---------
__device__ __host__ __forceinline__ void setValueInfra(CELL_TYPE *t_board, const int t_idx, const CELL_TYPE t_num)
{
    const int       offset        = t_idx << OFFSET_BITS_LOG2;
    const int       arrayIdx      = offset >> CELL_BITS_LOG2;
    const int       inArrayOffset = offset % CELL_BITS_LOG2;
    const CELL_TYPE mask          = t_num << inArrayOffset;
    t_board[arrayIdx] |= mask;
}

__device__ __host__ __forceinline__ CELL_TYPE getValueInfra(const CELL_TYPE *t_board, const int t_idx)
{
    const int offset        = t_idx << OFFSET_BITS_LOG2;
    const int arrayIdx      = offset >> CELL_BITS_LOG2;
    const int inArrayOffset = offset % CELL_BITS_SZ;
    CELL_TYPE value         = t_board[arrayIdx];
    value                   = value >> inArrayOffset & 0xF;
    return value;
}

__device__ __host__ __forceinline__ ConstraintsCoordinates getConstraintsIndexesInfra(const int t_BoardIdx)
{
    const int rowIdx    = t_BoardIdx / SUDOKU_SIZE;
    const int colIdx    = t_BoardIdx % SUDOKU_SIZE;
    const int squareIdx = rowIdx / 3 * 3 + colIdx / 3;
    return {rowIdx, colIdx, squareIdx};
}

#endif // SUDOKU_BOARD_INFRA_H
