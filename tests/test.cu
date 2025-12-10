#include <gtest/gtest.h>
#include <iomanip>
#include <numeric>
#include <string>

#include "io_manager.h"
#include "sudoku.cuh"

using DoubleMicros = std::chrono::duration<double, std::micro>;

class CPU_vs_GPU_Test : public ::testing::Test
{
    public:
    const int RESULTS_THE_SAME_TEST_SIZE = 2e6;
    const std::string RESULTS_THE_SAME_TEST_FILE = "../../sample_files/puzzles.csv";
    //"../../sample_files/sudoku_data.csv";

    const int GPU_MASSIVE_TEST = 2e6;
    const std::string PUZZLES_FILE = "../../sample_files/puzzles.csv";
    const std::string SOLUTIONS_FILE = "../../sample_files/solutions.csv";
};

TEST_F(CPU_vs_GPU_Test, only_GPU_Correctness)
{
    const auto encodedBoards = readInput(PUZZLES_FILE, GPU_MASSIVE_TEST);
    const auto solutionsBoards = readInput(SOLUTIONS_FILE, GPU_MASSIVE_TEST);
    const auto start = std::chrono::high_resolution_clock::now();
    const auto gpuResults = solveGPU(encodedBoards, GPU_MASSIVE_TEST);
    const auto stop = std::chrono::high_resolution_clock::now();
    const DoubleMicros gpuDuration = stop - start;
    std::cout << "Time taken GPU: " << std::fixed << std::setprecision(2) << gpuDuration.count() / 1e6 << " seconds\n";
    Board gpuTmp;

    for (size_t i = 0; i < GPU_MASSIVE_TEST; ++i) {
        gpuTmp.initBoard(i, gpuResults, MAX_GEN_BOARDS);
        const auto gpuStr = gpuTmp.getBoardString();
        const auto &tmpStr = solutionsBoards[i];
        const auto resultStr = tmpStr.substr(0, tmpStr.size() - 2);
        ASSERT_EQ(gpuStr, resultStr) << fmt::format("Failed at {}th board...", i);
    }
}


TEST_F(CPU_vs_GPU_Test, areCPUandGPU_resultsTheSame_Test)
{
    const auto encodedBoards = readInput(RESULTS_THE_SAME_TEST_FILE, RESULTS_THE_SAME_TEST_SIZE);
    auto start = std::chrono::high_resolution_clock::now();
    const auto gpuResults = solveGPU(encodedBoards, RESULTS_THE_SAME_TEST_SIZE);
    auto stop = std::chrono::high_resolution_clock::now();
    const DoubleMicros gpuDuration = stop - start;

    start = std::chrono::high_resolution_clock::now();
    const auto cpuResults = solveCPU(encodedBoards, RESULTS_THE_SAME_TEST_SIZE);
    stop = std::chrono::high_resolution_clock::now();
    const DoubleMicros cpuDuration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start);

    std::cout << "Time taken GPU: " << std::fixed << std::setprecision(2) << gpuDuration.count() / 1e6 << " seconds\n";
    std::cout << "Time taken CPU: " << std::fixed << std::setprecision(2) << cpuDuration.count() / 1e6 << " seconds\n";
    std::cout << "GPU speedup vs CPU version: " << std::fixed << std::setprecision(2) << cpuDuration.count() / gpuDuration.count() << "x\n";

    Board gpuTmp;
    for (size_t i = 0; i < RESULTS_THE_SAME_TEST_SIZE; ++i) {
        gpuTmp.initBoard(i, gpuResults, MAX_GEN_BOARDS);
        const auto gpuStr = gpuTmp.getBoardString();
        const auto cpuStr = cpuResults[i].getBoardString();
        ASSERT_EQ(gpuStr, cpuStr) << fmt::format("Failed at {}th board...", i);
    }
}