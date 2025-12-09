//
// Created by chefxx on 21.11.2025.
//

#ifndef SUDOKU_SPDLOG_MACROS_H
#define SUDOKU_SPDLOG_MACROS_H

#include <spdlog/spdlog.h>

namespace myLog {

inline void warning(std::string_view msg, std::string_view file = __FILE__, const int line = __LINE__)
{
    spdlog::warn("{}:{} {}", file, line, msg);
}

inline void error(std::string_view msg, std::string_view file = __FILE__, const int line = __LINE__)
{
    spdlog::error("{}:{} {}", file, line, msg);
}

inline void information(std::string_view msg, std::string_view file = __FILE__, const int line = __LINE__)
{
    spdlog::info("{}:{} {}", file, line, msg);
}

} // namespace myLog


#endif // SUDOKU_SPDLOG_MACROS_H
