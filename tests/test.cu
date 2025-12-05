#include <gtest/gtest.h>
#include <numeric>
#include <string>
#include "sudoku.cuh"

TEST(Whole, test)
{
    const std::vector<std::string> boards{"000400560010506090000097300009020040600005000000370000502000000063000000000960800"};
    auto [h_boardsBuff, h_constraintsBuff, initCreatedNum] = convertAndAlignSerial(boards, MAX_GEN_BOARDS);

    std::vector<uint32_t> h_rootsBuff(MAX_GEN_BOARDS);
    std::iota(h_rootsBuff.begin(), h_rootsBuff.begin() + initCreatedNum, 0);

    auto [d_boardsBuff_A, d_boardsBuff_B] = allocateGPUPair<CELL_TYPE>(BOARD_BUFF_N(MAX_GEN_BOARDS));
    auto [d_constraintsBuff_A, d_constraintsBuff_B] =
        allocateGPUPair<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_N(MAX_GEN_BOARDS));
    auto [d_rootsBuff_A, d_rootsBuff_B]              = allocateGPUPair<uint32_t>(ROOTS_BUFF_N(MAX_GEN_BOARDS));
    const auto [d_childrenCountBuff, d_cellNumsBuff] = allocateGPURest<uint32_t, uint16_t>(MAX_GEN_BOARDS);


    copyToGPU(d_boardsBuff_A,
              d_constraintsBuff_A,
              d_rootsBuff_A,
              h_boardsBuff,
              h_constraintsBuff,
              h_rootsBuff,
              MAX_GEN_BOARDS);

    launchChooseChildren(d_boardsBuff_A, d_constraintsBuff_A, d_childrenCountBuff, d_cellNumsBuff, initCreatedNum);
}