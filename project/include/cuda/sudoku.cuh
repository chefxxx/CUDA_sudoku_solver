//
// Created by chefxx on 25.11.2025.
//

#ifndef CUDA_SUDOKU_SUDOKU_H
#define CUDA_SUDOKU_SUDOKU_H

#include <string_view>
#include "board_defines.h"
#include "memory_cuda.cuh"

#define BOARD_BUFF_N(t_count) ((t_count) * SUDOKU_BITPACK_N)
#define BOARD_BUFF_SZ(t_count) (BOARD_BUFF_N(t_count) * sizeof(CELL_TYPE))
#define CONSTRAINTS_BUFF_N(t_count) ((t_count) * CONSTRAINTS_N * SUDOKU_SIZE)
#define CONSTRAINTS_BUFF_SZ(t_count) (CONSTRAINTS_BUFF_N(t_count) * sizeof(CONSTRAINTS_TYPE))
#define ROOTS_BUFF_N(t_count) (t_count)
#define ROOTS_BUFF_SZ(t_count) ((t_count) * sizeof(uint32_t))

__host__ void solve(std::string_view t_method, std::string_view t_inputFileName, int t_count);
__host__ void copyToGPU(const mem_cuda::unique_ptr<CELL_TYPE>        &t_dBoards,
                        const mem_cuda::unique_ptr<CONSTRAINTS_TYPE> &t_dConstraints,
                        const mem_cuda::unique_ptr<uint32_t>         &t_dRoots,
                        const std::vector<CELL_TYPE>                 &t_hBoards,
                        const std::vector<CONSTRAINTS_TYPE>          &t_hConstraints,
                        const std::vector<uint32_t>                  &t_hRoots,
                        size_t                                        t_count);

template <typename Type>
__host__ std::tuple<mem_cuda::unique_ptr<Type>, mem_cuda::unique_ptr<Type>> allocateGPUPair(size_t t_count)
{
    auto d_A = mem_cuda::make_unique<Type>(t_count);
    auto d_B = mem_cuda::make_unique<Type>(t_count);
    return std::make_tuple(std::move(d_A), std::move(d_B));
}

template <typename... Types>
__host__ std::tuple<mem_cuda::unique_ptr<Types>...> allocateGPURest(const size_t t_count)
{
    return std::tuple<mem_cuda::unique_ptr<Types>...>(mem_cuda::make_unique<Types>(t_count)...);
}

#endif
