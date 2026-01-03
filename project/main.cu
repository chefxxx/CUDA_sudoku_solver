#include <iostream>

#include "io_manager.h"
#include "sudoku.cuh"

void usage()
{
    std::cerr << "USAGE: ./sudoku <method> <count> <input_file.csv> <output_file.csv>\n";
    exit(EXIT_FAILURE);
}

int main(const int argc, const char **argv)
{
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
    const std::string inputFileName  = argv[3];
    const std::string outputFileName = argv[4];

    // ---------------
    // Read input file
    // ---------------
    std::cout << "Reading input file...\n";
    const auto encodedBoards = readInput(inputFileName, count);

    // ----------
    // Run solver
    // ----------

    // TODO: CPU solver
    if (method == "cpu")
        return EXIT_SUCCESS;
    if (method == "gpu") {
        const auto result = solveGPU(encodedBoards, count);
        std::cout << "Writing output to the file...\n";
        writeOutput(outputFileName, result, MAX_GEN_BOARDS, count);
    }

    return EXIT_SUCCESS;
}
