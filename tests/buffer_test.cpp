//
// Created by chefxx on 21.11.2025.
//

#include <gtest/gtest.h>
#include "solver_infra.h"
#include "io_manager.h"



TEST(BufferTest, does_convertAndAlignSerial_When_OneBoardSupplied_ReturnedValuesSizesMatch)
{
    const std::string boardStr = "000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    std::vector<std::string> testBoard;
    testBoard.push_back(boardStr);
    const auto [boardsBuff, constraintsBuff, createdNumber] = convertAndAlignSerial(testBoard);
    ASSERT_EQ(createdNumber, 1);
    ASSERT_EQ(boardsBuff.size(), 11);
    ASSERT_EQ(constraintsBuff.size(), 27);
}

TEST(BufferTest, does_convertAndAlignSerial_PreserveBoardStructure)
{
    const std::string boardStr2 = "000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    const std::string boardStr1 = "530070000600195000098000060800060003400803001700020006060000280000419005000080079";
    const std::string boardStr3 = "009000680040030200000709000600020004800000007300040006000907000007080040086000900";
    std::vector<std::string> testBoard;
    testBoard.push_back(boardStr1);
    testBoard.push_back(boardStr2);
    testBoard.push_back(boardStr3);

    // We are checking here if second board in buffer is the same as expected one
    const Board expected(convertLineToNumbers(boardStr2).value());
    const auto [boardsBuff, constraintsBuff, createdNumber] = convertAndAlignSerial(testBoard);
    // ReSharper disable once CppTooWideScope
    constexpr int secondOffset = 1;
    for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
        ASSERT_EQ(expected.inside[i], boardsBuff[secondOffset + i * 3]);
    }
}