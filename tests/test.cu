#include <gtest/gtest.h>
#include <iomanip>
#include <numeric>
#include <string>

#include "io_manager.h"
#include "sudoku.cuh"

class CPU_vs_GPU_Test : public ::testing::Test
{
    public:
    const int TEST_SIZE = 32000;
    const std::string TEST_FILE = "../../sample_files/sudoku_data.csv";
};


TEST_F(CPU_vs_GPU_Test, correctnessTest)
{
    using DoubleMicros = std::chrono::duration<double, std::micro>;
    const auto encodedBoards = readInput(TEST_FILE, TEST_SIZE);

    auto start = std::chrono::high_resolution_clock::now();
    const auto gpuResults = solveGPU(encodedBoards, TEST_SIZE);
    auto stop = std::chrono::high_resolution_clock::now();
    const DoubleMicros gpuDuration = stop - start;

    start = std::chrono::high_resolution_clock::now();
    const auto cpuResults = solveCPU(encodedBoards, TEST_SIZE);
    stop = std::chrono::high_resolution_clock::now();
    const DoubleMicros cpuDuration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start);

    std::cout << "Time taken GPU: " << std::fixed << std::setprecision(2) << gpuDuration.count() / 1e6 << " seconds\n";
    std::cout << "Time taken CPU: " << std::fixed << std::setprecision(2) << cpuDuration.count() / 1e6 << " seconds\n";
    std::cout << "GPU speedup vs CPU version: " << std::fixed << std::setprecision(2) << cpuDuration.count() / gpuDuration.count() << "x\n";

    Board gpuTmp;
    for (size_t i = 0; i < TEST_SIZE; ++i) {
        gpuTmp.initBoard(i, gpuResults, MAX_GEN_BOARDS);
        const auto gpuStr = gpuTmp.getBoardString();
        const auto cpuStr = cpuResults[i].getBoardString();
        ASSERT_EQ(gpuStr, cpuStr) << fmt::format("Failed at {}th board...", i);
    }
}