//
// Created by chefxx on 13.11.2025.
//

#include "solver_infra.h"

#include "io_manager.h"
#include "memory_cuda.cuh"
#include "spdlog_macros.h"

constexpr int MAX_GEN_BOARDS  = 1048576;
constexpr int MAX_GENERATIONS = 3;

std::optional<std::vector<CELL_TYPE>> convertLineToNumbers(const std::string_view t_line)
{
    std::vector<CELL_TYPE> numbers;
    // t_line has '\n' at the end, so we loop over first 81 elements
    for (int i = 0; i < SUDOKU_SIZE * SUDOKU_SIZE; ++i) {
        const auto c   = t_line[i];
        const auto num = c - '0';
        if (num < 0 || num > 9) {
            myLog::warn(fmt::format("Not valid character {} found!", num));
            return std::nullopt;
        }
        numbers.emplace_back(num);
    }
    return std::make_optional(numbers);
}

std::tuple<std::vector<CELL_TYPE>, std::vector<uint16_t>, int>
convertAndAlignSerial(const std::vector<std::string> &t_encodedBoards)
{
    int                    globalIdx = 0;
    std::vector<CELL_TYPE> globalBoards(SUDOKU_BITPACK_N * t_encodedBoards.size(), 0);
    std::vector<uint16_t>  globalConstraints(CONSTRAINTS_N * SUDOKU_SIZE * t_encodedBoards.size(), 0);

    for (const auto &board : t_encodedBoards) {
        const auto values = convertLineToNumbers(board);
        if (values.has_value()) {
            const BoardConstraints tmpC(values.value());
            if (!tmpC.isValid) {
                myLog::warn("Not valid board found!");
            }
            else {
                // save constraints to buffer
                const size_t offset = t_encodedBoards.size() * SUDOKU_SIZE;
                saveConstraintsToBuffer(globalConstraints.data(), offset, t_encodedBoards.size(), globalIdx, tmpC);

                // create board and save it to buffer
                createAndSaveBoardToBuffer(globalBoards.data(), t_encodedBoards.size(), globalIdx, values.value());
                globalIdx++;
            }
        }
    }
    return std::make_tuple(globalBoards, globalConstraints, globalIdx);
}

void saveConstraintsToBuffer(uint16_t               *t_buff,
                             const size_t            t_constraintOffset,
                             const size_t            t_boardsSize,
                             const size_t            t_globalIdx,
                             const BoardConstraints &t_currConstraints)
{
    for (int i = 0; i < CONSTRAINTS_N; ++i) {
        for (int k = 0; k < SUDOKU_SIZE; ++k) {
            t_buff[t_globalIdx + i * t_constraintOffset + k * t_boardsSize] = t_currConstraints.constraints[i][k];
        }
    }
}

void createAndSaveBoardToBuffer(CELL_TYPE                    *t_buff,
                                const size_t                  t_boardsSize,
                                const size_t                  t_globalIdx,
                                const std::vector<CELL_TYPE> &t_values)
{
    const Board tmpB(t_values);
    for (int i = 0; i < SUDOKU_BITPACK_N; ++i) {
        t_buff[t_globalIdx + i * t_boardsSize] = tmpB.inside[i];
    }
}

void solve(const std::string_view t_method, const std::string_view t_inputFileName, const int t_count)
{
    // TODO: CPU solver
    if (t_method == "cpu")
        return;

    // ---------------------
    // Read boards from file
    // ---------------------
    const auto encodedBoards = readInput(t_inputFileName, t_count);

    // ---------------------
    // Create buffers on CPU
    // ---------------------
    const auto [h_boardsBuff, h_constraintsBuff, h_createdNum] = convertAndAlignSerial(encodedBoards);
    myLog::info(fmt::format("Created {} boards out of {}.", h_createdNum, t_count));

    // -------------------------------------------------------------------------------
    // Allocate memory on GPU
    //
    // Preallocate big buffers in order to unique resizing when generating new boards.
    // Two buffers are used to read current boards and write new children.
    // -------------------------------------------------------------------------------
    myLog::info("Allocating GPU memory...");
    const auto d_boardsBuff_A      = cuda::make_unique<CELL_TYPE>(MAX_GEN_BOARDS * SUDOKU_BITPACK_N);
    const auto d_boardsBuff_B      = cuda::make_unique<CELL_TYPE>(MAX_GEN_BOARDS * SUDOKU_BITPACK_N);
    const auto d_constraintsBuff_A = cuda::make_unique<uint16_t>(MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE);
    const auto d_constraintsBuff_B = cuda::make_unique<uint16_t>(MAX_GEN_BOARDS * CONSTRAINTS_N * SUDOKU_SIZE);
    const auto d_childrenCountBuff = cuda::make_unique<uint16_t>(MAX_GEN_BOARDS);
    const auto d_BuffSize          = cuda::make_unique<int>();

    // ------------------
    // Copy memory to GPU
    // ------------------
    myLog::info("Copying data to GPU...");
    const size_t generatedBoards_sz      = sizeof(CELL_TYPE) * h_boardsBuff.size();
    const size_t generatedConstraints_sz = sizeof(uint16_t) * h_constraintsBuff.size();
    checkCudaErrors(cudaMemcpy(d_boardsBuff_A.get(), h_boardsBuff.data(), generatedBoards_sz, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy(
        d_constraintsBuff_A.get(), h_constraintsBuff.data(), generatedConstraints_sz, cudaMemcpyHostToDevice));
    checkCudaErrors(cudaMemcpy(d_BuffSize.get(), &h_createdNum, sizeof(int), cudaMemcpyHostToDevice));

    // -----------------------
    // Execute generation loop
    // -----------------------
    for (int i = 0; i < MAX_GENERATIONS; ++i) {
    }
}