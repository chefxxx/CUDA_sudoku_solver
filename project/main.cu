#include <cassert>
#include <iostream>

#include "board.h"
#include "io_manager.h"
#include "solver_infra.h"

void usage(const std::string &pname)
{
    std::cerr << "USAGE: " << pname << "<method> <count> <input.txt> <output.txt>\n";
    exit(EXIT_FAILURE);
}

int main(const int argc, const char **argv) {
    // --------------
    // Read arguments
    // --------------
    if (argc < 5)
        usage(argv[0]);
    const std::string method = argv[1];
    if (method.compare("gpu") != 0 && method.compare("cpu") != 0)
        usage(argv[0]);
    const int count = std::stoi(argv[2]);
    if (count < 1)
        usage(argv[0]);
    const std::string inputFileName = argv[3];
    const std::string outputFileName = argv[4];

    // -----------------------------
    // Divide input file into boards
    // -----------------------------
    const auto encodedBoards = readInput(inputFileName, count);

    // --------------------
    // Create boards on CPU
    // --------------------
    assert(encodedBoards.empty() == false);
    const auto boards = createBoardsSerial(encodedBoards);

    return EXIT_SUCCESS;
}
