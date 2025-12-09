//
// Created by chefxx on 02.12.2025.
//

#ifndef DFS_CUH
#define DFS_CUH

#include <stack>

#include "device_board.cuh"
#include "generate_boards.cuh"

constexpr int MAX_STACK_SIZE = 81;

__device__ __forceinline__ void solveOneBoard(DeviceBoard       &t_board,
                                              DeviceConstraints &t_constraints,
                                              uint16_t          *t_emptyBuff,
                                              uint16_t          *t_masksBuff,
                                              CELL_TYPE         *t_outBoardsBuff,
                                              uint32_t          *t_solutions,
                                              const size_t       t_globalStride,
                                              const size_t       t_rootIdx)
{
    int emptyIdx = 0;
    for (uint16_t i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; i++) {
        const CELL_TYPE val = t_board.getValue(i);
        if (!val) {
            t_emptyBuff[emptyIdx]   = i;
            t_masksBuff[emptyIdx++] = 0;
        }
    }

    t_masksBuff[0] = t_constraints.getConstraintsMask(t_emptyBuff[0]);
    uint16_t value;
    short    curr = 0;
    while (curr >= 0) {
        uint16_t idx = t_emptyBuff[curr];

        if (t_masksBuff[curr] > 0) {
            value = popLsb(t_masksBuff[curr]);
            t_board.setValue(idx, value);
            t_constraints.updateConstraints(value, idx);

            if (curr + 1 == emptyIdx) {
                const uint32_t old = atomicAdd(&t_solutions[t_rootIdx], 1);
                if (old == 0) { // this is the first one that have found a solution
                    saveBoardToBuffer(t_outBoardsBuff, t_rootIdx, t_board.cells, t_globalStride);
                }
                return;
            }

            curr++;
            t_masksBuff[curr] = t_constraints.getConstraintsMask(t_emptyBuff[curr]);
        }
        else {
            curr--;
            if (curr < 0)
                break;

            idx   = t_emptyBuff[curr];
            value = t_board.getValue(idx);
            t_constraints.revertConstraints(value, idx);
            t_board.setValue(idx, 0);
        }
    }
}

__global__ __forceinline__ void solveSudokuBoards(const CELL_TYPE        *t_inBoardsBuff,
                                                  CELL_TYPE              *t_outBoardsBuff,
                                                  const CONSTRAINTS_TYPE *t_constraintsBuff,
                                                  const uint32_t         *t_rootBuff,
                                                  uint32_t               *t_solutions,
                                                  const size_t            t_boardCount,
                                                  const size_t            t_globalStride)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    __shared__ uint16_t emptyBuffer[MAX_STACK_SIZE * THREADS_PER_BLOCK];
    __shared__ uint16_t masksBuffer[MAX_STACK_SIZE * THREADS_PER_BLOCK];

    uint16_t *empty = &emptyBuffer[MAX_STACK_SIZE * threadIdx.x];
    uint16_t *masks = &masksBuffer[MAX_STACK_SIZE * threadIdx.x];

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_inBoardsBuff, t_globalStride);
        constraints.initConstraints(work, t_constraintsBuff, t_globalStride);
        solveOneBoard(board, constraints, empty, masks, t_outBoardsBuff, t_solutions, t_globalStride, t_rootBuff[work]);
    }
}

__global__ __forceinline__ void solveSudokuBoards_ver3(const CELL_TYPE        *t_inBoardsBuff,
                                                       CELL_TYPE              *t_outBoardsBuff,
                                                       const CONSTRAINTS_TYPE *t_constraintsBuff,
                                                       const uint32_t         *t_rootBuff,
                                                       uint32_t               *t_solutions,
                                                       const size_t            t_boardCount,
                                                       const size_t            t_globalStride)
{
    const size_t tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const size_t workOffset = gridDim.x * blockDim.x;

    DeviceBoard       board{};
    DeviceConstraints constraints{};

    uint16_t emptyBuffer[MAX_STACK_SIZE];
    uint16_t masksBuffer[MAX_STACK_SIZE];

    for (size_t work = tid; work < t_boardCount; work += workOffset) {
        board.initBoard(work, t_inBoardsBuff, t_globalStride);
        constraints.initConstraints(work, t_constraintsBuff, t_globalStride);
        solveOneBoard(board,
                      constraints,
                      emptyBuffer,
                      masksBuffer,
                      t_outBoardsBuff,
                      t_solutions,
                      t_globalStride,
                      t_rootBuff[work]);
    }
}

__global__ __forceinline__ void solveSudokuBoards_ver2(const CELL_TYPE        *t_inBoardsBuff,
                                                       CELL_TYPE              *t_outBoardsBuff,
                                                       const CONSTRAINTS_TYPE *t_constraintsBuff,
                                                       const uint32_t         *t_rootBuff,
                                                       uint32_t               *t_solutions,
                                                       const size_t            t_boardCount,
                                                       const size_t            t_globalStride,
                                                       uint32_t               *t_globalWorkCounter)
{
    DeviceBoard       board{};
    DeviceConstraints constraints{};

    uint16_t emptyBuffer[MAX_STACK_SIZE];
    uint16_t masksBuffer[MAX_STACK_SIZE];

    while (true) {
        const size_t work = atomicAdd(t_globalWorkCounter, 1);

        if (work >= t_boardCount)
            break;

        board.initBoard(work, t_inBoardsBuff, t_globalStride);
        constraints.initConstraints(work, t_constraintsBuff, t_globalStride);
        solveOneBoard(board,
                      constraints,
                      emptyBuffer,
                      masksBuffer,
                      t_outBoardsBuff,
                      t_solutions,
                      t_globalStride,
                      t_rootBuff[work]);
    }
}

__host__ inline bool solveOneCPU(Board &t_board, BoardConstraints &t_boardConstraints)
{
    // variable to signal end of backtracking
    int emptyCount = countEmptyCPU(t_board);
    if (emptyCount == 0) return true;

    struct State {
        State(const int t_idx, CONSTRAINTS_TYPE const t_mask) : idx(t_idx), mask(t_mask) {}
        int idx;
        CONSTRAINTS_TYPE mask;
    };

    std::stack<State> stack;

    const auto firstIdx                    = findMCC_CPU(t_board, t_boardConstraints);
    const auto firstMask    = t_boardConstraints.getConstraintsMask(firstIdx);

    stack.push({firstIdx, firstMask});

    while (!stack.empty()) {
        State &curr = stack.top();

        if (curr.mask > 0) {
            const int value = popLsb(curr.mask);
            t_board.setValue(curr.idx, value);
            t_boardConstraints.updateConstraints(value, curr.idx);
            emptyCount--;

            if (emptyCount == 0) { // solved board...
                return true;
            }

            // choose next
            int nextIdx = findMCC_CPU(t_board, t_boardConstraints);
            auto nextMask = t_boardConstraints.getConstraintsMask(nextIdx);
            stack.push({nextIdx, nextMask});
        }
        else {
            stack.pop();
            if (stack.empty()) {
                return false;
            }

            const auto parent = stack.top();
            const auto value = t_board.getValue(parent.idx);
            t_boardConstraints.resetConstraints(value, parent.idx);
            t_board.setValue(parent.idx, 0);
            ++emptyCount;
        }
    }
    return false;
}

#endif // DFS_CUH