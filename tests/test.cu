#include <gtest/gtest.h>
#include <numeric>
#include <string>

#include "sudoku.cuh"

TEST(Whole, test)
{
    const std::vector<std::string> boards{
        "000400560010506090000097300009020040600005000000370000502000000063000000000960800"};
    const int test                                         = boards.size();
    auto [h_boardsBuff, h_constraintsBuff, initCreatedNum] = convertAndAlignSerial(boards, test);

    std::vector<uint32_t> h_rootsBuff(test);
    std::iota(h_rootsBuff.begin(), h_rootsBuff.begin() + initCreatedNum, 0);

    auto [d_boardsBuff_A, d_boardsBuff_B]            = allocateGPU_Pair<CELL_TYPE>(BOARD_BUFF_N(test));
    auto [d_constraintsBuff_A, d_constraintsBuff_B]  = allocateGPU_Pair<CONSTRAINTS_TYPE>(CONSTRAINTS_BUFF_N(test));
    auto [d_rootsBuff_A, d_rootsBuff_B]              = allocateGPU_Pair<uint32_t>(ROOTS_BUFF_N(test));
    const auto [d_childrenCountBuff, d_cellNumsBuff] = allocateGPU_AnySameSize<uint32_t, uint16_t>(test);


    copyToGPU(d_boardsBuff_A, d_constraintsBuff_A, d_rootsBuff_A, h_boardsBuff, h_constraintsBuff, h_rootsBuff, test);

    launchChooseChildren(
        d_boardsBuff_A, d_constraintsBuff_A, d_childrenCountBuff, d_cellNumsBuff, initCreatedNum, test);
}