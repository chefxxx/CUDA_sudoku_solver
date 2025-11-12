#include <iostream>

void usage(const std::string& pname)
{
    std::cerr << "USAGE: " << pname << " <input.txt> <output.txt>\n";
    exit(EXIT_FAILURE);
}

int main(const int argc, const char ** argv) {

    if (argc < 3) {
        usage(argv[0]);
    }
    return 0;
}
