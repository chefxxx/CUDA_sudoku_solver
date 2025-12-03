//
// Created by chefxx on 02.12.2025.
//

#ifndef DFS_CUH
#define DFS_CUH

constexpr int STACK_MAX_SIZE = 81;

struct DeviceStack
{
    __device__ DeviceStack() : top(-1) {}
    __device__ bool isEmpty() const { return top == -1; }
    __device__ bool isFull() const { return top == STACK_MAX_SIZE - 1; }
    __device__ void push(const uint16_t t_value)
    {
        if (isFull())
            return;
        cells[top++] = t_value;
    }
    __device__ uint16_t pop()
    {
        if (isEmpty())
            return -1;
        const auto popped = cells[top];
        top--;
        return popped;
    }
    __device__ uint16_t peek() const
    {
        if (isEmpty())
            return -1;
        return cells[top];
    }

    uint16_t cells[STACK_MAX_SIZE] = {};
    uint16_t top;
};

__global__ void solveSudokuBoards(const CELL_TYPE *t_boardsBuff, const CONSTRAINTS_TYPE *t_constraintsBuff, size_t t_boardCount);

__device__ __forceinline__ void solveOneBoard(DeviceBoard &t_board, DeviceConstraints &t_constraints)
{

}

#endif // DFS_CUH