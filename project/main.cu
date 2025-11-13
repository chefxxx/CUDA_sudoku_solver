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
    const auto encodedBoards = readInput(argv[1]);

    // --------------------
    // Create boards on CPU
    // --------------------
    assert(encodedBoards.empty() == false);



    return EXIT_SUCCESS;
}
