//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_SOLVER_H
#define CUDA_SUDOKU_SOLVER_H

#include <optional>
#include <string>
#include <vector>

#include "board_infra.cuh"
#include "host_board.cuh"

constexpr int THREADS_PER_BLOCK = 128;
constexpr int MAX_GEN_BOARDS    = 1048576;
constexpr int MAX_GENERATIONS   = 1;

__host__ std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(std::string_view t_line);
__host__                                       std::tuple<std::vector<CELL_TYPE>, std::vector<CONSTRAINTS_TYPE>, int>
                                               convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards);

void saveConstraintsToBuffer(CONSTRAINTS_TYPE       *t_buff,
                             size_t                  t_constraintOffset,
                             size_t                  t_globalIdx,
                             const BoardConstraints &t_currConstraints,
                             size_t                  t_stride);
void createAndSaveBoardToBuffer(CELL_TYPE                    *t_buff,
                                size_t                        t_globalIdx,
                                const std::vector<CELL_TYPE> &t_values,
                                size_t                        t_stride);

#endif // CUDA_SUDOKU_SOLVER_H
