#include <gtest/gtest.h>

#include "host_board.cuh"
#include "solver_infra.cuh"
/**
 * @brief This test checks whether getValue()/setValue() work correctly.
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

TEST(BoardInfraTest, does_setValue_and_getValue_work)
{
    const std::string boardStr = "000260701680070090190004500820100040004602900050003028009300074040050036703018000";
    const std::vector expected{
        0,0,0,2,6,0,7,0,1,
        6,8,0,0,7,0,0,9,0,
        1,9,0,0,0,4,5,0,0,
        8,2,0,1,0,0,0,4,0,
        0,0,4,6,0,2,9,0,0,
        0,5,0,0,0,3,0,2,8,
        0,0,9,3,0,0,0,7,4,
        0,4,0,0,5,0,0,3,6,
        7,0,3,0,1,8,0,0,0
    };
    const Board board{convertLineToNumbers((boardStr)).value()};
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        ASSERT_EQ(expected[i], board.getValue(i));
    }
}