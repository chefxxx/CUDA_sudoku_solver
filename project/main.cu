#include <iostream>

#include "board.h"
#include "io_manager.h"
#include "solver_infra.h"

void usage(const std::string& pname)
{
    std::cerr << "USAGE: " << pname << " <input.txt> <output.txt>\n";
    exit(EXIT_FAILURE);
}

int main(const int argc, const char **argv) {
    // --------------
    // Read arguments
    // --------------
    if (argc < 3) {
        usage(argv[0]);
    }

    // -----------------------------
    // Divide input file into boards
    // -----------------------------
    const auto [encodedBoards, puzzleSize] = readInput(argv[1]);

    // -----------------------
    // Run appropriate solvers
    // -----------------------
    assert(encodedBoards.empty() == false);

    switch (puzzleSize) {
        case PUZZLE_9:
            mainForGivenSize<PUZZLE_9>(encodedBoards);
            break;
        case PUZZLE_16:
            mainForGivenSize<PUZZLE_16>(encodedBoards);
            break;
        default:
            std::cerr << "Invalid board size: " << puzzleSize << " :(\n";
            exit(EXIT_FAILURE);
    }

    return EXIT_SUCCESS;
}
