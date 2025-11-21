//
// Created by chefxx on 21.11.2025.
//

#ifndef SUDOKU_SPDLOG_MACROS_H
#define SUDOKU_SPDLOG_MACROS_H

#include <source_location>
#include <spdlog/spdlog.h>

namespace myLog {

inline void warn(std::string_view msg, const std::source_location loc = std::source_location::current())
{
    spdlog::warn("{}:{} {}", loc.file_name(), loc.line(), msg);
}

inline void err(std::string_view msg, const std::source_location loc = std::source_location::current())
{
    spdlog::error("{}:{} {}", loc.file_name(), loc.line(), msg);
}

inline void info(std::string_view msg, const std::source_location loc = std::source_location::current())
{
    spdlog::info("{}:{} {}", loc.file_name(), loc.line(), msg);
}

} // namespace myLog


#endif // SUDOKU_SPDLOG_MACROS_H
