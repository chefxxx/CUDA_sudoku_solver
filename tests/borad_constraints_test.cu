//
// Created by chefxx on 14.11.2025.
//

#include <bitset>
#include <gtest/gtest.h>

#include "../project/include/cpu/host_board.h"
#include "solver_infra.cuh"

/**
 * @brief This test checks whether row constraints are set properly.
 *
 * Sudoku board:
 * 0 0 0 | 2 6 0 | 7 0 1
 * 6 8 0 | 0 7 0 | 0 9 0
 * 1 9 0 | 0 0 4 | 5 0 0
 * ------+-------+------
 * 8 2 0 | 1 0 0 | 0 4 0
 * 0 0 4 | 6 0 2 | 9 0 0
 * 0 5 0 | 0 0 3 | 0 2 8
 * ------+-------+------
 * 0 0 9 | 3 0 0 | 0 7 4
 * 0 4 0 | 0 5 0 | 0 3 6
 * 7 0 3 | 0 1 8 | 0 0 0
 */
class BoardConstraintsTest : public testing::Test
{
public:
    const std::string boardStr = "000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    BoardConstraints  boardC;

protected:
    BoardConstraintsTest()
        : boardC(convertLineToNumbers(boardStr).value())
    {
    }
};

TEST_F(BoardConstraintsTest, doesConstraintsIndexesMatch)
{
    std::vector<std::tuple<int, int, int>> expected = {
        {0, 0, 0}, {0, 1, 0}, {0, 2, 0}, {0, 3, 1}, {0, 4, 1}, {0, 5, 1}, {0, 6, 2}, {0, 7, 2}, {0, 8, 2},
        {1, 0, 0}, {1, 1, 0}, {1, 2, 0}, {1, 3, 1}, {1, 4, 1}, {1, 5, 1}, {1, 6, 2}, {1, 7, 2}, {1, 8, 2},
        {2, 0, 0}, {2, 1, 0}, {2, 2, 0}, {2, 3, 1}, {2, 4, 1}, {2, 5, 1}, {2, 6, 2}, {2, 7, 2}, {2, 8, 2},

        {3, 0, 3}, {3, 1, 3}, {3, 2, 3}, {3, 3, 4}, {3, 4, 4}, {3, 5, 4}, {3, 6, 5}, {3, 7, 5}, {3, 8, 5},
        {4, 0, 3}, {4, 1, 3}, {4, 2, 3}, {4, 3, 4}, {4, 4, 4}, {4, 5, 4}, {4, 6, 5}, {4, 7, 5}, {4, 8, 5},
        {5, 0, 3}, {5, 1, 3}, {5, 2, 3}, {5, 3, 4}, {5, 4, 4}, {5, 5, 4}, {5, 6, 5}, {5, 7, 5}, {5, 8, 5},

        {6, 0, 6}, {6, 1, 6}, {6, 2, 6}, {6, 3, 7}, {6, 4, 7}, {6, 5, 7}, {6, 6, 8}, {6, 7, 8}, {6, 8, 8},
        {7, 0, 6}, {7, 1, 6}, {7, 2, 6}, {7, 3, 7}, {7, 4, 7}, {7, 5, 7}, {7, 6, 8}, {7, 7, 8}, {7, 8, 8},
        {8, 0, 6}, {8, 1, 6}, {8, 2, 6}, {8, 3, 7}, {8, 4, 7}, {8, 5, 7}, {8, 6, 8}, {8, 7, 8}, {8, 8, 8}};
    for (int i = 0; i < expected.size(); ++i) {
        auto [rowIdx, colIdx, squareIdx]          = BoardConstraints::getConstraintsIndexes(i);
        auto [ex_rowIdx, ex_colIdx, ex_squareIdx] = expected[i];
        ASSERT_EQ(rowIdx, ex_rowIdx);
        ASSERT_EQ(colIdx, ex_colIdx);
        ASSERT_EQ(squareIdx, ex_squareIdx);
    }
}

TEST_F(BoardConstraintsTest, areRowConstraintsValid)
{
    // ReSharper disable once CppTooWideScope
    const std::bitset<16> expectedRows[SUDOKU_SIZE] = {
        0b0000001100111000, // 0, Not used: 3,4,5,8,9
        0b0000000000111110, // 1, Not used: 1,2,3,4,5
        0b0000000111001100, // 2, Not used: 2,3,6,7,8
        0b0000001011101000, // 3, Not used: 3,5,6,7,9
        0b0000000110101010, // 4, Not used: 1,3,5,7,8
        0b0000001011010010, // 5, Not used: 1,4,6,7,9
        0b0000000101100110, // 6, Not used: 1,2,5,6,8
        0b0000001110000110, // 7, Not used: 1,2,7,8,9
        0b0000001001110100  // 8, Not used: 2,4,5,6,9
    };

    for (int i = 0; i < SUDOKU_SIZE; ++i) {
        EXPECT_EQ(std::bitset<16>(boardC.constraints[row][i]), expectedRows[i]) << "Row " << i << " failed";
    }
}

/**
 * @brief This test checks whether column constraints are set properly.
 */
TEST_F(BoardConstraintsTest, areColConstraintsValid)
{
    const std::bitset<16> expectedCols[SUDOKU_SIZE] = {
        0b0000001000111100, // Not used: 2,3,4,5,9
        0b0000000011001010, // Not used:
        0b0000000111100110, // Not used:
        0b0000001110110000, // Not used:
        0b0000001100011100, // Not used:
        0b0000001011100010, // Not used:
        0b0000000101011110, // Not used:
        0b0000000101100010, // Not used:
        0b0000001010101100  // Not used:
    };

    for (int i = 0; i < SUDOKU_SIZE; ++i) {
        EXPECT_EQ(std::bitset<16>(boardC.constraints[col][i]), expectedCols[i]) << "Column " << i << " failed";
    }
}