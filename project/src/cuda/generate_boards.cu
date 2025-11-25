//
// Created by chefxx on 25.11.2025.
//

#include "generate_boards.cuh"
#include <cstdio>

__global__ void chooseChildren(CELL_TYPE *t_boardsBuff, uint16_t *t_constraintsBuff, uint16_t *t_childrenBuff, const int *t_boardCount)
{
    const int tid        = blockDim.x * blockIdx.x + threadIdx.x;
    const int workOffset = gridDim.x * blockDim.x;
    const int N          = *t_boardCount;

    for (int work = tid; work < N; work += workOffset) {

    }
}

__global__ void createChildren() {}
