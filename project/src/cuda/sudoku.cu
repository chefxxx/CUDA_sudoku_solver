//
// Created by chefxx on 25.11.2025.
//

#include <numeric>
#include <thrust/execution_policy.h>
#include <thrust/reduce.h>
#include <thrust/scan.h>
#include <cuda_profiler_api.h>

#include "dfs.cuh"
#include "generate_boards.cuh"
#include "io_manager.h"
#include "solver_infra.cuh"
#include "spdlog_macros.h"
#include "sudoku.cuh"
#include "profiler_wrapper.h"

void copyToGPU(const mem_cuda::unique_ptr<CELL_TYPE>        &t_dBoards,
               const mem_cuda::unique_ptr<CONSTRAINTS_TYPE> &t_dConstraints,
               const mem_cuda::unique_ptr<uint32_t>         &t_dRoots,
               const std::vector<CELL_TYPE>                 &t_hBoards,
               const std::vector<CONSTRAINTS_TYPE>          &t_hConstraints,
               const std::vector<uint32_t>                  &t_hRoots,
               const size_t                                  t_count)
{
    checkCudaErrors(cudaMemcpy(t_dBoards.get(), t_hBoards.data(), BOARD_BUFF_SZ(t_count), cudaMemcpyHostToDevice));
    checkCudaErrors(
        cudaMemcpy(t_dConstraints.get(), t_hConstraints.data(), CONSTRAINTS_BUFF_SZ(t_count), cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy(t_dRoots.get(), t_hRoots.data(), ROOTS_BUFF_SZ(t_count), cudaMemcpyHostToDevice));
}

__host__ void solve(const std::string_view t_inputFileName, const std::string_view t_outputFileName, const int t_count)
{
    // ---------------------
    // Read boards from file
    // ---------------------
    myLog::info("Reading input file...");
    const auto encodedBoards = readInput(t_inputFileName, t_count);

    // ---------------------
    // Create buffers on CPU
    // ---------------------
    myLog::info("Storing boards to CPU buffers...");
    auto [h_boardsBuff, h_constraintsBuff, initCreatedNum] = convertAndAlignSerial(encodedBoards, MAX_GEN_BOARDS);

    myLog::info(fmt::format("Created {} boards out of {}.", initCreatedNum, t_count));
    std::vector<uint32_t> h_rootsBuff(MAX_GEN_BOARDS);
    std::iota(h_rootsBuff.begin(), h_rootsBuff.begin() + initCreatedNum, 0);

    // -------------------------------------------------------------------------------
    // Allocate memory on GPU
    //
    // Preallocate big buffers in order to avoid resizing when generating new boards.
    // Two buffers are used to read current boards and write new children.
    // -------------------------------------------------------------------------------
    myLog::info("Allocating GPU memory...");
    auto [d_boardsBuff_A, d_boardsBuff_B] = allocateGPU_Pair<CELL_TYPE>(BOARD_BUFF_N(MAX_GEN_BOARDS));
    auto [d_constraintsBuff_A, d_constraintsBuff_B] =
        allocateGPU_Pair<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_N(MAX_GEN_BOARDS));
    auto [d_rootsBuff_A, d_rootsBuff_B]              = allocateGPU_Pair<uint32_t>(ROOTS_BUFF_N(MAX_GEN_BOARDS));
    const auto [d_childrenCountBuff, d_cellNumsBuff] = allocateGPU_AnySameSize<uint32_t, uint16_t>(MAX_GEN_BOARDS);

    // ------------------
    // Copy memory to GPU
    // ------------------
    myLog::info("Copying data to GPU...");
    copyToGPU(d_boardsBuff_A,
              d_constraintsBuff_A,
              d_rootsBuff_A,
              h_boardsBuff,
              h_constraintsBuff,
              h_rootsBuff,
              MAX_GEN_BOARDS);

    // -----------------------------
    // Execute board generation loop
    // -----------------------------
    size_t currentNum = initCreatedNum;
    size_t nextNum    = initCreatedNum;

    // -----------------
    // init work counter
    // -----------------
    const auto d_workCounter = mem_cuda::make_unique<uint32_t>();

    myLog::info("Executing board generation loop...");
    {
        PROFILE_SCOPE("BFS loop");
        for (int i = 0; i < MAX_GENERATIONS; ++i) {
            {
                PROFILE_SCOPE("Choose Children");
                reset_counter<<<1, 1>>>(d_workCounter.get());
                CUDA_CHECK_KERNEL();
                CUDA_SYNC_CHECK();

                chooseChildren_ver2<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(
                    d_boardsBuff_A.get(),
                    d_constraintsBuff_A.get(),
                    d_childrenCountBuff.get(),
                    d_cellNumsBuff.get(),
                    currentNum,
                    MAX_GEN_BOARDS,
                    d_workCounter.get());
                CUDA_CHECK_KERNEL();
                CUDA_SYNC_CHECK();
            }

            // Reduce and exclusive scan to get new number of boards and offsets
            nextNum = thrust::reduce(thrust::device, d_childrenCountBuff.get(), d_childrenCountBuff.get() + currentNum);
            if (nextNum > MAX_GEN_BOARDS) {
                myLog::info(fmt::format(
                    "Stopping at {} generations, board generation limit of {} boards exceeded!", i, MAX_GEN_BOARDS));
                break;
            }

            thrust::exclusive_scan(thrust::device,
                                   d_childrenCountBuff.get(),
                                   d_childrenCountBuff.get() + currentNum,
                                   d_childrenCountBuff.get());

            {

                PROFILE_SCOPE("Create Children");
                reset_counter<<<1, 1>>>(d_workCounter.get());
                CUDA_CHECK_KERNEL();
                CUDA_SYNC_CHECK();

                createChildren_ver2<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_boardsBuff_A.get(),
                                                                       d_boardsBuff_B.get(),
                                                                       d_constraintsBuff_A.get(),
                                                                       d_constraintsBuff_B.get(),
                                                                       d_rootsBuff_A.get(),
                                                                       d_rootsBuff_B.get(),
                                                                       d_childrenCountBuff.get(),
                                                                       d_cellNumsBuff.get(),
                                                                       currentNum,
                                                                       MAX_GEN_BOARDS,
                                                                       d_workCounter.get());
                CUDA_CHECK_KERNEL();
                CUDA_SYNC_CHECK();
            }

            // update buffers
            d_boardsBuff_A.swap(d_boardsBuff_B);
            d_constraintsBuff_A.swap(d_constraintsBuff_B);
            d_rootsBuff_A.swap(d_rootsBuff_B);
            currentNum = nextNum;
        }
    }

    myLog::info(fmt::format("Generated {} boards...", currentNum));
    std::vector<uint32_t> h_solutions(t_count, 0);
    const auto            d_solutions = allocateAndCopyGPU_FromHostVector(h_solutions);

    myLog::info("Running main solver kernel...");
    {
        PROFILE_SCOPE("DFS step");
        reset_counter<<<1, 1>>>(d_workCounter.get());
        CUDA_CHECK_KERNEL();
        CUDA_SYNC_CHECK();

        solveSudokuBoards_ver2<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_boardsBuff_A.get(),
                                                                  d_boardsBuff_B.get(),
                                                                  d_constraintsBuff_A.get(),
                                                                  d_rootsBuff_A.get(),
                                                                  d_solutions.get(),
                                                                  currentNum,
                                                                  MAX_GEN_BOARDS,
                                                                  d_workCounter.get());
        CUDA_CHECK_KERNEL();
        CUDA_SYNC_CHECK();
    }

    myLog::info("Copying results to the host...");
    checkCudaErrors(
        cudaMemcpy(h_boardsBuff.data(), d_boardsBuff_B.get(), BOARD_BUFF_SZ(MAX_GEN_BOARDS), cudaMemcpyDeviceToHost));
    checkCudaErrors(cudaMemcpy(
        h_solutions.data(), d_solutions.get(), h_solutions.size() * sizeof(uint32_t), cudaMemcpyDeviceToHost));

    myLog::info("Writing output to the file...");
    writeOutput(t_outputFileName, h_boardsBuff, MAX_GEN_BOARDS, t_count);
}
