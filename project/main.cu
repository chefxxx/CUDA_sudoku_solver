#include <iostream>
#include "io_manager.h"
#include "board.h"

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
    const auto [encodedBoards, boardSize] = readInput(argv[1]);

    // -------------
    // Create boards
    // -------------
    assert(encodedBoards.empty() == false);


    return EXIT_SUCCESS;
}
