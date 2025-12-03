//
// Created by chefxx on 02.12.2025.
//

#ifndef DFS_CUH
#define DFS_CUH

#include "device_board.cuh"
#include "generate_boards.cuh"

constexpr int MAX_STACK_SIZE = 81;

__global__ void solveSudokuBoards(const CELL_TYPE        *t_inBoardsBuff,
                                  CELL_TYPE              *t_outBoardsBuff,
                                  const CONSTRAINTS_TYPE *t_constraintsBuff,
                                  const uint32_t         *t_rootBuff,
                                  size_t                  t_boardCount);

__device__ __forceinline__ void solveOneBoard(DeviceBoard       &t_board,
                                              DeviceConstraints &t_constraints,
                                              uint16_t          *t_emptyBuff,
                                              uint16_t          *t_masksBuff,
                                              CELL_TYPE         *t_outBoardsBuff,
                                              const size_t       t_globalOffset)
{
    int emptyIdx = 0;
    for (uint16_t i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; i++) {
        const CELL_TYPE val = t_board.getValue(i);
        if (!val) {
            t_emptyBuff[emptyIdx] = i;
            t_masksBuff[emptyIdx++] = 0;
        }
    }

    t_masksBuff[0] = t_constraints.getConstraintsMask(t_emptyBuff[0]);
    uint16_t value;
    short curr = 0;
    while (curr >= 0) {
        uint16_t idx = t_emptyBuff[curr];

        if (t_masksBuff[curr] > 0) {
            value = popLsb(t_masksBuff[curr]);
            t_board.setValue(idx, value);
            t_constraints.updateConstraints(value, idx);

            if (curr + 1 == emptyIdx) {
                // store board
                saveBoardToBuffer(t_outBoardsBuff, t_globalOffset, t_board.cells, MAX_GEN_BOARDS);
                return;
            }

            curr++;
            t_masksBuff[curr] = t_constraints.getConstraintsMask(t_emptyBuff[curr]);
        }
        else {
            curr--;
            if (curr < 0) break;

            idx = t_emptyBuff[curr];
            value = t_board.getValue(idx);
            t_constraints.revertConstraints(value, idx);
            t_board.setValue(idx, 0);
        }
    }
}

#endif // DFS_CUH