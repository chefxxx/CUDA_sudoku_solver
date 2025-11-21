#include <iostream>

#include "board.h"
#include "io_manager.h"
#include "solver_infra.h"
#include "spdlog/spdlog.h"

void usage()
{
    std::cerr << "USAGE: ./sudoku <method> <count> <input.txt> <output.txt>\n";
    exit(EXIT_FAILURE);
}

int main(const int argc, const char **argv) {
    // --------------
    // Read arguments
    // --------------
    if (argc < 5)
        usage();
    const std::string method = argv[1];
    if (method != "gpu" && method != "cpu")
        usage();
    const int count = std::stoi(argv[2]);
    if (count < 1)
        usage();
    const std::string inputFileName = argv[3];
    const std::string outputFileName = argv[4];

    // ------------------------------
    // Divide input file into strings
    // ------------------------------
    const auto encodedBoards = readInput(inputFileName, count);

    // --------------------
    // Create boards on CPU
    // --------------------


    return EXIT_SUCCESS;
}
