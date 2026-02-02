//
// Created by chefxx on 25.11.2025.
//

#include <cuda_profiler_api.h>
#include <numeric>
#include <thread>
#include <thrust/execution_policy.h>
#include <thrust/reduce.h>
#include <thrust/scan.h>

#include "dfs.cuh"
#include "generate_boards.cuh"
#include "io_manager.h"
#include "solver_infra.cuh"
#include "sudoku.cuh"
#include "logger.h"

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

__host__ std::vector<CELL_TYPE>
solveGPU(const std::vector<std::string> &t_encodedBoards, const int t_count)
{
    // ---------------------
    // Time management utils
    // ---------------------
    auto startTimer = []() {
        return std::chrono::high_resolution_clock::now();
    };

    auto stopTimer = [](auto start) {
        auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double> elapsed = end - start;
        std::ostringstream oss;
        oss << std::fixed << std::setprecision(3) << " (" << elapsed.count() << "s)";
        return oss.str();
    };


    // ---------------------
    // Create buffers on CPU
    // ---------------------
    logger::info("Reading the input file...\n");

    const auto timer1 = startTimer();
    auto [h_boardsBuff, h_constraintsBuff, initCreatedNum, MIN_ZEROS] = convertAndAlignSerial(t_encodedBoards, MAX_GEN_BOARDS);
    std::vector<uint32_t> h_rootsBuff(MAX_GEN_BOARDS);
    std::string time1 = stopTimer(timer1);
    std::iota(h_rootsBuff.begin(), h_rootsBuff.begin() + initCreatedNum, 0);

    logger::info("Reading the input file - Finished! {}\n", time1);

    // -------------------------------------------------------------------------------
    // Allocate memory on GPU
    //
    // Preallocate big buffers in order to avoid resizing when generating new boards.
    // Two buffers are used to read current boards and write new children.
    // -------------------------------------------------------------------------------
    logger::info("Allocating GPU memory...\n");

    const auto timer2= startTimer();
    auto [d_boardsBuff_A, d_boardsBuff_B] = allocateGPU_Pair<CELL_TYPE>(BOARD_BUFF_N(MAX_GEN_BOARDS));
    auto [d_constraintsBuff_A, d_constraintsBuff_B] =
        allocateGPU_Pair<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_N(MAX_GEN_BOARDS));
    auto [d_rootsBuff_A, d_rootsBuff_B]              = allocateGPU_Pair<uint32_t>(ROOTS_BUFF_N(MAX_GEN_BOARDS));
    const auto [d_childrenCountBuff, d_cellNumsBuff] = allocateGPU_AnySameSize<uint32_t, uint16_t>(MAX_GEN_BOARDS);
    std::string time2 = stopTimer(timer2);

    logger::info("Allocating GPU memory - Finished! {}\n", time2);

    // ------------------
    // Copy memory to GPU
    // ------------------
    logger::info("Copying data to GPU...\n");

    const auto timer3 = startTimer();
    copyToGPU(d_boardsBuff_A,
              d_constraintsBuff_A,
              d_rootsBuff_A,
              h_boardsBuff,
              h_constraintsBuff,
              h_rootsBuff,
              MAX_GEN_BOARDS);
    std::string time3 = stopTimer(timer3);

    logger::info("Copying data to GPU - Finished! {}\n", time3);

    // -----------------------------
    // Execute board generation loop
    // -----------------------------
    size_t currentNum = initCreatedNum;
    size_t nextNum    = initCreatedNum;

    // -----------------
    // init work counter
    // -----------------
    const auto d_workCounter = mem_cuda::make_unique<uint32_t>();
    const auto MAX_GENERATIONS = MIN_ZEROS - 1;

    logger::info("Solving boards...\n");

    const auto timer4 = startTimer();
    for (int i = 0; i < MAX_GENERATIONS; ++i) {
        reset_counter<<<1, 1>>>(d_workCounter.get());
        getLastCudaError("Kernel failed...");
        checkCudaErrors(cudaDeviceSynchronize());

        chooseChildren_ver2<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_boardsBuff_A.get(),
                                                                    d_constraintsBuff_A.get(),
                                                                    d_childrenCountBuff.get(),
                                                                    d_cellNumsBuff.get(),
                                                                    currentNum,
                                                                    MAX_GEN_BOARDS,
                                                                    d_workCounter.get());
        getLastCudaError("Kernel failed...");
        checkCudaErrors(cudaDeviceSynchronize());

        // Reduce and exclusive scan to get new number of boards and offsets
        nextNum = thrust::reduce(thrust::device, d_childrenCountBuff.get(), d_childrenCountBuff.get() + currentNum);
        if (nextNum > MAX_GEN_BOARDS) {
            logger::warn("Stopping at generations, board generation limit of boards exceeded!\n");
        }

        thrust::exclusive_scan(thrust::device,
                               d_childrenCountBuff.get(),
                               d_childrenCountBuff.get() + currentNum,
                               d_childrenCountBuff.get());

        reset_counter<<<1, 1>>>(d_workCounter.get());
        getLastCudaError("Kernel failed...");
        checkCudaErrors(cudaDeviceSynchronize());

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
        getLastCudaError("Kernel failed...");
        checkCudaErrors(cudaDeviceSynchronize());

        // update buffers
        d_boardsBuff_A.swap(d_boardsBuff_B);
        d_constraintsBuff_A.swap(d_constraintsBuff_B);
        d_rootsBuff_A.swap(d_rootsBuff_B);
        currentNum = nextNum;
    }


    std::vector<uint32_t> h_solutions(t_count, 0);
    const auto            d_solutions = allocateAndCopyGPU_FromHostVector(h_solutions);

    reset_counter<<<1, 1>>>(d_workCounter.get());
    getLastCudaError("Kernel failed...");
    checkCudaErrors(cudaDeviceSynchronize());

    solveSudokuBoards_ver2<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_boardsBuff_A.get(),
                                                                   d_boardsBuff_B.get(),
                                                                   d_constraintsBuff_A.get(),
                                                                   d_rootsBuff_A.get(),
                                                                   d_solutions.get(),
                                                                   currentNum,
                                                                   MAX_GEN_BOARDS,
                                                                   d_workCounter.get());
    getLastCudaError("Kernel failed...");
    checkCudaErrors(cudaDeviceSynchronize());
    std::string time4 = stopTimer(timer4);

    logger::info("Solving boards - Finished! {}\n", time4);
    logger::info("Copying results to the host...\n");

    const auto timer5 = startTimer();
    checkCudaErrors(cudaMemcpy(h_boardsBuff.data(), d_boardsBuff_B.get(), BOARD_BUFF_SZ(MAX_GEN_BOARDS), cudaMemcpyDeviceToHost));
    checkCudaErrors(cudaMemcpy(h_solutions.data(), d_solutions.get(), h_solutions.size() * sizeof(uint32_t), cudaMemcpyDeviceToHost));
    std::string time5 = stopTimer(timer5);

    logger::info("Copying results to the host - Finished! {}\n", time5);

    return h_boardsBuff;
}
