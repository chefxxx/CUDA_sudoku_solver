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
constexpr int CONSTRAINTS_N    = 3;

// ------------------------
// Main gpu solver settings
// ------------------------
constexpr int THREADS_PER_BLOCK = 128;
constexpr int BLOCKS_PER_GRID   = 128;
constexpr int MAX_GEN_BOARDS    = 4194304;
constexpr int MAX_GENERATIONS   = 30;

// -------------
// Buffers sizes
// -------------
#define BOARD_BUFF_N(t_count)        ((t_count) * SUDOKU_BITPACK_N)
#define BOARD_BUFF_SZ(t_count)       (BOARD_BUFF_N(t_count) * sizeof(CELL_TYPE))
#define CONSTRAINTS_BUFF_N(t_count)  ((t_count) * CONSTRAINTS_N * SUDOKU_SIZE)
#define CONSTRAINTS_BUFF_SZ(t_count) (CONSTRAINTS_BUFF_N(t_count) * sizeof(CONSTRAINTS_TYPE))
#define ROOTS_BUFF_N(t_count)        (t_count)
#define ROOTS_BUFF_SZ(t_count)       ((t_count) * sizeof(uint32_t))

// ---------------
// Macro debugging
// ---------------
#ifdef NDEBUG
    #define CUDA_CHECK_KERNEL()
    #define CUDA_SYNC_CHECK()
#else
    #define CUDA_CHECK_KERNEL() getLastCudaError("Kernel failed...")
    #define CUDA_SYNC_CHECK() checkCudaErrors(cudaDeviceSynchronize())
#endif


#endif // SUDOKU_BOARD_DEFINES_H
