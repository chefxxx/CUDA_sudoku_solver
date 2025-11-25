message("Loading project...")

# ------------------------------------------------------------------------------ #
# Gather source files #
# ------------------------------------------------------------------------------ #

file(GLOB CUDA_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/cuda/*.cu" )
file(GLOB CXX_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/cpu/*.cpp" )

# ------------------------------------------------------------------------------ #
# Define cuda lib #
# ------------------------------------------------------------------------------ #

message("Loading CUDA library...")

add_library(${CUDA_LIB} STATIC ${CUDA_SOURCES})

set(CMAKE_CUDA_ARCHITECTURES 60 61)

# CUDA Architecture setting
set_property(TARGET ${CUDA_LIB} PROPERTY CUDA_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES})
message("Supported CUDA architectures: " "${CMAKE_CUDA_ARCHITECTURES}")

target_include_directories(${CUDA_LIB} PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/include/cuda"
        "${CMAKE_CURRENT_SOURCE_DIR}/include/cuda_utils"
)

target_link_libraries(${CUDA_LIB} PUBLIC CUDA::cudart ${HOST_LIB})

# When this property is ON, CMake passes the '-dc' flag to nvcc, which compiles
# each CUDA source file into relocatable device code. This allows device functions
# defined in one translation unit (.cu file) to be called from another — e.g., across
# libraries or in the final executable.
#
# This is required if CUDA_LIB exposes device symbols that are linked
# later (by another library or executable). Otherwise, device linkage would fail.
#
# Note: Each target that contains CUDA sources and defines or calls device
# functions must have this property enabled separately.
set_target_properties(${CUDA_LIB} PROPERTIES CUDA_SEPARABLE_COMPILATION ON)

# ------------------------------------------------------------------------------ #
# Define cxx lib #
# ------------------------------------------------------------------------------ #

message("Loading CXX library...")

add_library(${HOST_LIB} STATIC ${CXX_SOURCES})
target_include_directories(${HOST_LIB} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include/cpu")
target_link_libraries(${HOST_LIB} PUBLIC spdlog::spdlog)

# ------------------------------------------------------------------------------ #
# Define executable #
# ------------------------------------------------------------------------------ #

add_executable(${MAIN} main.cu)

# The main executable also launches CUDA kernels and may contain
# device code, so we enable separable compilation here as well.
set_target_properties(${MAIN} PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
target_link_libraries(${MAIN} PUBLIC ${CUDA_LIB})

# ------------------------------------------------------------------------------ #
# Compilation settings #
# ------------------------------------------------------------------------------ #

# Set build type to RELEASE by default:
if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "No build type provided, default to RELEASE.")
    set(CMAKE_BUILD_TYPE "RELEASE")
endif ()

message("Build type: " "${CMAKE_BUILD_TYPE}")

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message("Using GNU complier...")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        message("Using Clang...")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        message("Using MSVC...")
    else ()
        message(FATAL_ERROR "Compiler " "${CXX_COMPILER_ID}" " is not supported.")
    endif ()
    target_compile_options(${HOST_LIB} PRIVATE
            $<$<CXX_COMPILER_ID:GNU>:-g -O0 -Wall -Wextra -pedantic -Wshadow -Wnon-virtual-dtor -Werror>
            $<$<CXX_COMPILER_ID:Clang>:-g -O0 -Wall -Wextra -pedantic -Wshadow -Wnon-virtual-dtor -Werror>
            $<$<CXX_COMPILER_ID:MSVC>:/W4>
    )
    target_compile_options(${CUDA_LIB} PRIVATE
            -v
            --generate-line-info
            -g3
            -fno-omit-frame-pointer
            -G
            -O0
            -Xcompiler -g
            -Xcompiler -O0
            -Xcompiler -Wall
            -Xcompiler -Wextra
    )
elseif (CMAKE_BUILD_TYPE STREQUAL "Release")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message("Using GNU complier...")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        message("Using Clang...")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        message("Using MSVC...")
    else ()
        message(FATAL_ERROR "Compiler " "${CXX_COMPILER_ID}" " is not supported.")
    endif ()
    target_compile_options(${HOST_LIB} PRIVATE
            $<$<CXX_COMPILER_ID:GNU>:-O3 -march=native -funroll-loops>
            $<$<CXX_COMPILER_ID:Clang>:-O3 -march=native -funroll-loops>
            $<$<CXX_COMPILER_ID:MSVC>:> 
    )
    target_compile_options(${CUDA_LIB} PRIVATE
            -Xptxas -O3
            -Xcompiler -O3
            -Xcompiler -march=native
            -Xcompiler -funroll-loops
    )
else()
    message(FATAL_ERROR "Unknown build type.")
endif ()
