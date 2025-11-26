//
// Created by chefxx on 25.11.2025.
//

#include "solver_infra.cuh"
#include "generate_boards.cuh"
#include "io_manager.h"
#include "memory_cuda.cuh"
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
    const auto [h_boardsBuff, h_constraintsBuff, h_createdNum] = convertAndAlignSerial(encodedBoards);
    myLog::info(fmt::format("Created {} boards out of {}.", h_createdNum, t_count));

    // -------------------------------------------------------------------------------
    // Allocate memory on GPU
    //
    // Preallocate big buffers in order to avoid resizing when generating new boards.
    // Two buffers are used to read current boards and write new children.
    // -------------------------------------------------------------------------------
    myLog::info("Allocating GPU memory...");
    const auto d_boardsBuff_A      = cuda::make_unique<CELL_TYPE>(MAX_GEN_BOARDS * SUDOKU_BITPACK_N);
    const auto d_boardsBuff_B      = cuda::make_unique<CELL_TYPE>(MAX_GEN_BOARDS * SUDOKU_BITPACK_N);
    const auto d_constraintsBuff_A = cuda::make_unique<uint16_t>(MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE);
    const auto d_constraintsBuff_B = cuda::make_unique<uint16_t>(MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE);
    const auto d_childrenCountBuff = cuda::make_unique<uint16_t>(MAX_GEN_BOARDS);
    const auto d_BuffSize          = cuda::make_unique<int>();

    // ------------------
    // Copy memory to GPU
    // ------------------
    myLog::info("Copying data to GPU...");
    const size_t generatedBoards_sz      = sizeof(CELL_TYPE) * h_boardsBuff.size();
    const size_t generatedConstraints_sz = sizeof(uint16_t) * h_constraintsBuff.size();
    checkCudaErrors(cudaMemcpy(d_boardsBuff_A.get(), h_boardsBuff.data(), generatedBoards_sz, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy(
        d_constraintsBuff_A.get(), h_constraintsBuff.data(), generatedConstraints_sz, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy(d_BuffSize.get(), &h_createdNum, sizeof(int), cudaMemcpyHostToDevice));

    // -----------------------
    // Execute generation loop
    // -----------------------
    myLog::info("Executing board generation loop...");
    for (int i = 0; i < MAX_GENERATIONS; ++i) {
        checkCudaErrors(cudaDeviceSynchronize());
        chooseChildren<<<1, 1>>>(
            d_boardsBuff_A.get(), d_constraintsBuff_A.get(), d_childrenCountBuff.get(), d_BuffSize.get());
        getLastCudaError("chooseChildren kernel failed!");
        checkCudaErrors(cudaDeviceSynchronize());
    }
}