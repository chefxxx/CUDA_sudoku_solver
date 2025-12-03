//
// Created by chefxx on 25.11.2025.
//

#include <numeric>
#include <thrust/execution_policy.h>
#include <thrust/reduce.h>
#include <thrust/scan.h>

#include "generate_boards.cuh"
#include "io_manager.h"
#include "memory_cuda.cuh"
#include "solver_infra.cuh"
#include "spdlog_macros.h"

constexpr size_t BOARD_BUFF_N        = MAX_GEN_BOARDS * SUDOKU_BITPACK_N;
constexpr size_t BOARD_BUFF_SZ       = sizeof(CELL_TYPE) * BOARD_BUFF_N;
constexpr size_t CONSTRAINTS_BUFF_N  = MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE;
constexpr size_t CONSTRAINTS_BUFF_SZ = sizeof(CONSTRAINTS_TYPE) * CONSTRAINTS_BUFF_N;
constexpr size_t ROOTS_BUFF_SZ       = sizeof(uint32_t) * MAX_GEN_BOARDS;

void solve(const std::string_view t_method, const std::string_view t_inputFileName, const int t_count)
{
    // TODO: CPU solver
    if (t_method == "cpu")
        return;

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
    auto       d_boardsBuff_A      = mem_cuda::make_unique<CELL_TYPE>(BOARD_BUFF_N);
    auto       d_boardsBuff_B      = mem_cuda::make_unique<CELL_TYPE>(BOARD_BUFF_SZ);
    auto       d_constraintsBuff_A = mem_cuda::make_unique<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_N);
    auto       d_constraintsBuff_B = mem_cuda::make_unique<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_SZ);
    auto       d_rootsBuff_A       = mem_cuda::make_unique<uint32_t>(MAX_GEN_BOARDS);
    auto       d_rootsBuff_B       = mem_cuda::make_unique<uint32_t>(MAX_GEN_BOARDS);
    const auto d_childrenCountBuff = mem_cuda::make_unique<uint32_t>(MAX_GEN_BOARDS);
    const auto d_cellNumsBuff = mem_cuda::make_unique<uint16_t>(MAX_GEN_BOARDS);

    // ------------------
    // Copy memory to GPU
    // ------------------
    myLog::info("Copying data to GPU...");
    checkCudaErrors(cudaMemcpy(d_boardsBuff_A.get(), h_boardsBuff.data(), BOARD_BUFF_SZ, cudaMemcpyHostToDevice));
    checkCudaErrors(
        cudaMemcpy(d_constraintsBuff_A.get(), h_constraintsBuff.data(), CONSTRAINTS_BUFF_SZ, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy(d_rootsBuff_A.get(), h_rootsBuff.data(), ROOTS_BUFF_SZ, cudaMemcpyHostToDevice));

    // -----------------------------
    // Execute board generation loop
    // -----------------------------
    size_t currentNum = initCreatedNum;
    size_t nextNum    = initCreatedNum;
    myLog::info("Executing board generation loop...");
    for (int i = 0; i < MAX_GENERATIONS; ++i) {
        checkCudaErrors(cudaDeviceSynchronize());
        chooseChildren<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_boardsBuff_A.get(),
                                 d_constraintsBuff_A.get(),
                                 d_childrenCountBuff.get(),
                                 d_cellNumsBuff.get(),
                                 currentNum);
        getLastCudaError("chooseChildren kernel failed!");
        checkCudaErrors(cudaDeviceSynchronize());

        // Reduce and exclusive scan to get new number of boards and offsets
        nextNum = thrust::reduce(thrust::device, d_childrenCountBuff.get(), d_childrenCountBuff.get() + currentNum);
        if (nextNum > MAX_GEN_BOARDS) {
            myLog::info(fmt::format("Stopping at {} generations, board generation limit exceeded!", i));
            break;
        }

        thrust::exclusive_scan(thrust::device,
                               d_childrenCountBuff.get(),
                               d_childrenCountBuff.get() + currentNum,
                               d_childrenCountBuff.get());

        checkCudaErrors(cudaDeviceSynchronize());
        createChildren<<<THREADS_PER_BLOCK, BLOCKS_PER_GRID>>>(d_boardsBuff_A.get(),
                                 d_boardsBuff_B.get(),
                                 d_constraintsBuff_A.get(),
                                 d_constraintsBuff_B.get(),
                                 d_rootsBuff_A.get(),
                                 d_rootsBuff_B.get(),
                                 d_childrenCountBuff.get(),
                                 d_cellNumsBuff.get(),
                                 currentNum);
        getLastCudaError("createChildren kernel failed!");
        checkCudaErrors(cudaDeviceSynchronize());

        // update buffers
        d_boardsBuff_A.swap(d_boardsBuff_B);
        d_constraintsBuff_A.swap(d_constraintsBuff_B);
        d_rootsBuff_A.swap(d_rootsBuff_B);
        currentNum = nextNum;
    }

    myLog::info(fmt::format("Generated {} boards...", currentNum));

    // checkCudaErrors(cudaMemcpy(h_boardsBuff.data(), d_boardsBuff_A.get(), BOARD_BUFF_SZ, cudaMemcpyDeviceToHost));
    // checkCudaErrors(cudaMemcpy(h_rootsBuff.data(), d_rootsBuff_A.get(), ROOTS_BUFF_SZ, cudaMemcpyDeviceToHost));
    // for (int i = 0; i < currentNum; ++i) {
    //     Board tmp;
    //     tmp.initBoard(i, h_boardsBuff, MAX_GEN_BOARDS);
    //     std::cout << "root board: " << h_rootsBuff[i] << '\n';
    //     tmp.printBoard();
    // }
}