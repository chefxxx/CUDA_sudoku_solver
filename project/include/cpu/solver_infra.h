//
// Created by chefxx on 12.11.2025.
//

#ifndef CUDA_SUDOKU_SOLVER_H
#define CUDA_SUDOKU_SOLVER_H

template <size_t PuzzleSize>
std::vector<Board<PuzzleSize>> createBoards(const std::vector<std::string>& lines)
{
    std::vector<Board<PuzzleSize>> boards;
    for (const auto& line : lines) {
        boards.emplace_back(line);
    }
    return boards;
}

template <size_t PuzzleSize>
void mainForGivenSize(const std::vector<std::string>& lines)
{
    // ---------------------
    // Creation of boards,
    // possible time measure
    // ---------------------
    auto boards = createBoards<PuzzleSize>(lines);

}


#endif // CUDA_SUDOKU_SOLVER_H
