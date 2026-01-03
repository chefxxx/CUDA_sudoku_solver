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
    // Create buffers on CPU
    // ---------------------
    std::cout << "Storing boards to CPU buffers...\n";
    auto [h_boardsBuff, h_constraintsBuff, initCreatedNum, MIN_ZEROS] = convertAndAlignSerial(t_encodedBoards, MAX_GEN_BOARDS);
    std::vector<uint32_t> h_rootsBuff(MAX_GEN_BOARDS);
    std::iota(h_rootsBuff.begin(), h_rootsBuff.begin() + initCreatedNum, 0);
    std::cout << "Creating boards...\n";

    // -------------------------------------------------------------------------------
    // Allocate memory on GPU
    //
    // Preallocate big buffers in order to avoid resizing when generating new boards.
    // Two buffers are used to read current boards and write new children.
    // -------------------------------------------------------------------------------
    std::cout << "Allocating GPU memory...\n";
    auto [d_boardsBuff_A, d_boardsBuff_B] = allocateGPU_Pair<CELL_TYPE>(BOARD_BUFF_N(MAX_GEN_BOARDS));
    auto [d_constraintsBuff_A, d_constraintsBuff_B] =
        allocateGPU_Pair<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_N(MAX_GEN_BOARDS));
    auto [d_rootsBuff_A, d_rootsBuff_B]              = allocateGPU_Pair<uint32_t>(ROOTS_BUFF_N(MAX_GEN_BOARDS));
    const auto [d_childrenCountBuff, d_cellNumsBuff] = allocateGPU_AnySameSize<uint32_t, uint16_t>(MAX_GEN_BOARDS);

    // ------------------
    // Copy memory to GPU
    // ------------------
    std::cout << "Copying data to GPU...\n";
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
    const auto MAX_GENERATIONS = MIN_ZEROS - 1;
    std::cout << "Setting MAX_GENERATIONS for BFS gen to {}...\n";

    std::cout << "Executing board generation loop...\n";
    for (int i = 0; i < MAX_GENERATIONS; ++i) {
        reset_counter<<<1, 1>>>(d_workCounter.get());
        CUDA_CHECK_KERNEL();
        CUDA_SYNC_CHECK();



        chooseChildren_ver2<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_boardsBuff_A.get(),
                                                                    d_constraintsBuff_A.get(),
                                                                    d_childrenCountBuff.get(),
                                                                    d_cellNumsBuff.get(),
                                                                    currentNum,
                                                                    MAX_GEN_BOARDS,
                                                                    d_workCounter.get());
        CUDA_CHECK_KERNEL();
        CUDA_SYNC_CHECK();

        // Reduce and exclusive scan to get new number of boards and offsets
        nextNum = thrust::reduce(thrust::device, d_childrenCountBuff.get(), d_childrenCountBuff.get() + currentNum);
        if (nextNum > MAX_GEN_BOARDS) {
            std::cout << "Stopping at generations, board generation limit of boards exceeded!\n";
        }

        thrust::exclusive_scan(thrust::device,
                               d_childrenCountBuff.get(),
                               d_childrenCountBuff.get() + currentNum,
                               d_childrenCountBuff.get());

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


        // update buffers
        d_boardsBuff_A.swap(d_boardsBuff_B);
        d_constraintsBuff_A.swap(d_constraintsBuff_B);
        d_rootsBuff_A.swap(d_rootsBuff_B);
        currentNum = nextNum;
    }


    std::cout << "Generated boards...\n";
    std::vector<uint32_t> h_solutions(t_count, 0);
    const auto            d_solutions = allocateAndCopyGPU_FromHostVector(h_solutions);

    std::cout << "Running main solver kernel...\n";
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

    std::cout << "Copying results to the host...\n";
    checkCudaErrors(cudaMemcpy(h_boardsBuff.data(), d_boardsBuff_B.get(), BOARD_BUFF_SZ(MAX_GEN_BOARDS), cudaMemcpyDeviceToHost));
    checkCudaErrors(cudaMemcpy(h_solutions.data(), d_solutions.get(), h_solutions.size() * sizeof(uint32_t), cudaMemcpyDeviceToHost));

    return h_boardsBuff;
}

std::vector<Board> solveCPU(const std::vector<std::string> &t_encodedBoards, const int t_count)
{
    auto [boards, constraints] = createCPU(t_encodedBoards);

    // check possible threads count
    unsigned int numThreads = std::thread::hardware_concurrency();
    if (numThreads == 0)
        numThreads = 2;

    // create work vector
    std::vector<std::thread> threads;
    threads.reserve(numThreads);
    const int chunkSize = (t_count + numThreads - 1) / numThreads;

    for (int i = 0; i < t_count; ++i) {
        const int startIdx = i * chunkSize;
        int endIdx = std::min(startIdx + chunkSize, t_count);

        if (startIdx >= t_count) break;

        threads.emplace_back([&, startIdx, endIdx]() {
            for (int j = startIdx; j < endIdx; ++j) {
                if (!solveOneCPU(boards[j], constraints[j])) {
                    std::cout << "Failed to solve board on CPU!\n";
                }
            }
        });
    }

    for (auto &t : threads) {
        if (t.joinable()) {
            t.join();
        }
    }
    return boards;
}
