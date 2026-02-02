//
// Created by chefxx on 25.11.2025.
//

#ifndef CUDA_SUDOKU_SUDOKU_H
#define CUDA_SUDOKU_SUDOKU_H

#include <string_view>

#include "defines.h"
#include "generate_boards.cuh"
#include "memory_cuda.cuh"

__host__      std::vector<CELL_TYPE>
              solveGPU(const std::vector<std::string> &t_encodedBoards, int t_count);
__host__ void copyToGPU(const mem_cuda::unique_ptr<CELL_TYPE>        &t_dBoards,
                        const mem_cuda::unique_ptr<CONSTRAINTS_TYPE> &t_dConstraints,
                        const mem_cuda::unique_ptr<uint32_t>         &t_dRoots,
                        const std::vector<CELL_TYPE>                 &t_hBoards,
                        const std::vector<CONSTRAINTS_TYPE>          &t_hConstraints,
                        const std::vector<uint32_t>                  &t_hRoots,
                        size_t                                        t_count);

__global__ void reset_counter(uint32_t *t_counter)
{
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        *t_counter = 0;
    }
}

template <typename Type>
__host__ std::tuple<mem_cuda::unique_ptr<Type>, mem_cuda::unique_ptr<Type>> allocateGPU_Pair(const size_t t_count)
{
    auto d_A = mem_cuda::make_unique<Type>(t_count);
    auto d_B = mem_cuda::make_unique<Type>(t_count);
    return std::make_tuple(std::move(d_A), std::move(d_B));
}

template <typename... Types>
__host__ std::tuple<mem_cuda::unique_ptr<Types>...> allocateGPU_AnySameSize(const size_t t_count)
{
    return std::tuple<mem_cuda::unique_ptr<Types>...>(mem_cuda::make_unique<Types>(t_count)...);
}

template <typename Type> __host__ mem_cuda::unique_ptr<Type> allocateAndCopyGPU_FromHostVector(std::vector<Type> t_host)
{
    auto d_ptr = mem_cuda::make_unique<Type>(t_host.size());
    checkCudaErrors(cudaMemcpy(d_ptr.get(), t_host.data(), sizeof(Type) * t_host.size(), cudaMemcpyHostToDevice));
    return d_ptr;
}

#endif
