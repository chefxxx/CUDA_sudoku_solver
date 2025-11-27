//
// Created by chefxx on 25.11.2025.
//

#include <thrust/scan.h>
#include <thrust/reduce.h>
#include <thrust/execution_policy.h>

#include "generate_boards.cuh"
#include "io_manager.h"
#include "memory_cuda.cuh"
#include "solver_infra.cuh"
#include "spdlog_macros.h"

void solve(const std::string_view t_method, const std::string_view t_inputFileName, const int t_count)
{
    // TODO: CPU solver
    if (t_method == "cpu")
        return;

    // ---------------------
    // Read boards from file
    // ---------------------
    const auto encodedBoards = readInput(t_inputFileName, t_count);

    // ---------------------
    // Create buffers on CPU
    // ---------------------
    const auto [h_boardsBuff, h_constraintsBuff, initCreatedNum] = convertAndAlignSerial(encodedBoards, MAX_GEN_BOARDS);
    myLog::info(fmt::format("Created {} boards out of {}.", initCreatedNum, t_count));

    // -------------------------------------------------------------------------------
    // Allocate memory on GPU
    //
    // Preallocate big buffers in order to avoid resizing when generating new boards.
    // Two buffers are used to read current boards and write new children.
    // -------------------------------------------------------------------------------
    myLog::info("Allocating GPU memory...");
    const auto d_boardsBuff_A      = mem_cuda::make_unique<CELL_TYPE>(MAX_GEN_BOARDS * SUDOKU_BITPACK_N);
    const auto d_boardsBuff_B      = mem_cuda::make_unique<CELL_TYPE>(MAX_GEN_BOARDS * SUDOKU_BITPACK_N);
    const auto d_constraintsBuff_A = mem_cuda::make_unique<CONSTRAINTS_TYPE>(MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE);
    const auto d_constraintsBuff_B = mem_cuda::make_unique<CONSTRAINTS_TYPE>(MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE);
    const auto d_childrenCountBuff = mem_cuda::make_unique<uint16_t>(MAX_GEN_BOARDS);
    const auto d_cellNumsBuff      = mem_cuda::make_unique<uint16_t>(MAX_GEN_BOARDS);

    // ------------------
    // Copy memory to GPU
    // ------------------
    myLog::info("Copying data to GPU...");
    constexpr size_t generatedBoards_sz      = sizeof(CELL_TYPE) * MAX_GEN_BOARDS * SUDOKU_BITPACK_N;
    constexpr size_t generatedConstraints_sz = sizeof(CONSTRAINTS_TYPE) * MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE;
    checkCudaErrors(cudaMemcpy(d_boardsBuff_A.get(), h_boardsBuff.data(), generatedBoards_sz, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy(d_constraintsBuff_A.get(), h_constraintsBuff.data(), generatedConstraints_sz, cudaMemcpyHostToDevice));

    // -----------------------
    // Execute generation loop
    // -----------------------
    int currentNum = initCreatedNum;
    myLog::info("Executing board generation loop...");
    for (int i = 0; i < MAX_GENERATIONS; ++i) {
        checkCudaErrors(cudaDeviceSynchronize());
        chooseChildren<<<1, 1>>>(d_boardsBuff_A.get(),
                                 d_constraintsBuff_A.get(),
                                 d_childrenCountBuff.get(),
                                 d_cellNumsBuff.get(),
                                 currentNum);
        getLastCudaError("chooseChildren kernel failed!");
        checkCudaErrors(cudaDeviceSynchronize());

        currentNum = thrust::reduce(thrust::device, d_childrenCountBuff.get(), d_childrenCountBuff.get() + currentNum);
        thrust::exclusive_scan(thrust::device, d_childrenCountBuff.get(), d_childrenCountBuff.get() + currentNum, d_childrenCountBuff.get());

    }
}