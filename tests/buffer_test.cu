//
// Created by chefxx on 21.11.2025.
//

#include <gtest/gtest.h>

#include "../project/include/cuda/solver_infra.cuh"
#include "helper_cuda.h"
#include "spdlog/fmt/bundled/ranges.h"

class BufferTest : public ::testing::Test
{
public:
    const std::string boardStr2 = "000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    const std::string boardStr1 = "530070000600195000098000060800060003400803001700020006060000280000419005000080079";
    const std::string boardStr3 = "009000680040030200000709000600020004800000007300040006000907000007080040086000900";

    std::vector<std::string> test1;
    std::vector<std::string> test2;

protected:
    void SetUp() override
    {
        test1.push_back(boardStr1);
        test2.push_back(boardStr1);
        test2.push_back(boardStr2);
        test2.push_back(boardStr3);
    }
};

TEST_F(BufferTest, does_convertAndAlignSerial_When_OneBoardSupplied_ReturnedValuesSizesMatch)
{
    const auto [boardsBuff, constraintsBuff, createdNumber] = convertAndAlignSerial(test1);
    ASSERT_EQ(createdNumber, 1);
    ASSERT_EQ(boardsBuff.size(), 11 * MAX_GEN_BOARDS);
    ASSERT_EQ(constraintsBuff.size(), 27 * MAX_GEN_BOARDS);
}

TEST_F(BufferTest, does_convertAndAlignSerial_PreserveBoardStructure)
{
    // We are checking here if second board in buffer is the same as expected one
    const Board expected(convertLineToNumbers(boardStr2).value());
    const auto [boardsBuff, constraintsBuff, createdNumber] = convertAndAlignSerial(test2);
    // ReSharper disable once CppTooWideScope
    constexpr int secondOffset = 1;
    for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
        ASSERT_EQ(expected.inside[i], boardsBuff[secondOffset + i * MAX_GEN_BOARDS]);
    }
}

TEST_F(BufferTest, does_convertAndAlignSerial_PreserveConstraintsStructure)
{
    const BoardConstraints expected(convertLineToNumbers(boardStr2).value());
    const auto [boardsBuff, constraintsBuff, createdNumber] = convertAndAlignSerial(test2);
    // ReSharper disable once CppTooWideScope
    constexpr int secondOffset = 1;
    for (int i = 0; i < CONSTRAINTS_N; ++i) {
        for (int k = 0; k < SUDOKU_SIZE; ++k) {
            ASSERT_EQ(expected.constraints[i][k], constraintsBuff[secondOffset + i * MAX_GEN_BOARDS * SUDOKU_SIZE + k * MAX_GEN_BOARDS])
                << fmt::format("Failed at i={}, k={}", i, k);
        }
    }
}