#include <iostream>

#include "sudoku.cuh"

void usage()
{
    std::cerr << "USAGE: ./sudoku <method> <count> <input.txt> <output.txt>\n";
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

    // ----------
    // Run solver
    // ----------

    // TODO: CPU solver
    if (method == "cpu")
        return EXIT_SUCCESS;
    if (method == "gpu")
        solve(inputFileName, outputFileName, count);

    return EXIT_SUCCESS;
}
