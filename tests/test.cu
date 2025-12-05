#include <gtest/gtest.h>
#include <numeric>
#include <string>
#include "sudoku.cuh"

TEST(Whole, test)
{
    constexpr int testSize = 1;
    const std::vector<std::string> boards{"000400560010506090000097300009020040600005000000370000502000000063000000000960800"};
    auto [h_boardsBuff, h_constraintsBuff, initCreatedNum] = convertAndAlignSerial(boards, testSize);

    std::vector<uint32_t> h_rootsBuff(testSize);
    std::iota(h_rootsBuff.begin(), h_rootsBuff.begin() + initCreatedNum, 0);

    auto [d_boardsBuff_A, d_boardsBuff_B]                     = allocateGPUPair<CELL_TYPE>(BOARD_BUFF_N(testSize));
    auto [d_constraintsBuff_A, d_constraintsBuff_B] = allocateGPUPair<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_N(testSize));
    auto [d_rootsBuff_A, d_rootsBuff_B]                       = allocateGPUPair<uint32_t>(ROOTS_BUFF_N(testSize));
    const auto [d_childrenCountBuff, d_cellNumsBuff] = allocateGPURest<uint32_t, uint16_t>(testSize);

    copyToGPU(d_boardsBuff_A,
              d_constraintsBuff_A,
              d_rootsBuff_A,
              h_boardsBuff,
              h_constraintsBuff,
              h_rootsBuff,
              testSize);

    launchChooseChildren(d_boardsBuff_A, d_constraintsBuff_A, d_childrenCountBuff, d_cellNumsBuff, initCreatedNum);
}