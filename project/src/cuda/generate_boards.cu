//
// Created by chefxx on 25.11.2025.
//

#include "generate_boards.cuh"
#include <cstdio>

__global__ void chooseChildren(CELL_TYPE *boardsBuff, uint16_t *constraintsBuff, uint16_t *childrenBuff)
{
    printf("Hello from kernel!\n");
}

__global__ void createChildren() {}
