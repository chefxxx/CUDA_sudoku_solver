message("Loading project...")

# ------------------------------------------------------------------------------ #
# Gather source files #
# ------------------------------------------------------------------------------ #

file(GLOB SOURCES
        "${CMAKE_CURRENT_SOURCE_DIR}/src/cuda/*.cu"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/cpu/*.cpp"
)

# ------------------------------------------------------------------------------ #
# Define shared lib #
# ------------------------------------------------------------------------------ #

message("Loading CUDA library...")

add_library(${CUDA_LIB} SHARED ${SOURCES})

set(CMAKE_CUDA_ARCHITECTURES 61)

# CUDA Architecture setting
set_property(TARGET ${CUDA_LIB} PROPERTY CUDA_ARCHITECTURES ${CMAKE_CUDA_ARCHITECTURES})
message("Supported CUDA architectures: " "${CMAKE_CUDA_ARCHITECTURES}")

target_include_directories(${CUDA_LIB} PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/include/cpu"
        "${CMAKE_CURRENT_SOURCE_DIR}/include/cuda"
        "${CMAKE_CURRENT_SOURCE_DIR}/include/cuda_utils"
        ${CUDAToolkit_INCLUDE_DIRS}
)

target_link_libraries(${CUDA_LIB} PUBLIC CUDA::cudart spdlog::spdlog)

set_target_properties(${CUDA_LIB} PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON
        CUDA_RESOLVE_DEVICE_SYMBOLS ON
)


# ------------------------------------------------------------------------------ #
# Define executable #
# ------------------------------------------------------------------------------ #

add_executable(${MAIN} main.cu)
target_link_libraries(${MAIN} PRIVATE ${CUDA_LIB})

# ------------------------------------------------------------------------------ #
# Compilation settings #
# ------------------------------------------------------------------------------ #

# Set build type to RELEASE by default:
if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "No build type provided, default to RELEASE.")
    set(CMAKE_BUILD_TYPE "RELEASE")
endif ()

message("Build type " "${CMAKE_BUILD_TYPE}")
message("Using host compiler " ${CMAKE_CXX_COMPILER_ID})

# C++ compile options
target_compile_options(${CUDA_LIB} PUBLIC
        # MSVC
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:MSVC>,$<COMPILE_LANGUAGE:CXX>>: /W4 /Od>
        $<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:MSVC>,$<COMPILE_LANGUAGE:CXX>>: /O2>
        # GNU/Clang
        $<$<AND:$<CONFIG:Debug>,$<COMPILE_LANGUAGE:CXX>>: -g -O0 -Wall -Wextra -pedantic -Wshadow -Wnon-virtual-dtor -Werror>
        $<$<AND:$<CONFIG:Release>,$<COMPILE_LANGUAGE:CXX>>: -O3 -march=native -funroll-loops>
)

# CUDA compile options
target_compile_options(${CUDA_LIB} PUBLIC
        $<$<AND:$<CONFIG:Debug>,$<COMPILE_LANGUAGE:CUDA>>: -v -g3 -fno-omit-frame-pointer -G -O0>
        $<$<AND:$<CONFIG:Release>,$<COMPILE_LANGUAGE:CUDA>>: --ptxas-options=-v -Xptxas -O3>

        $<$<AND:$<CONFIG:Release>,$<COMPILE_LANGUAGE:CUDA>,$<CXX_COMPILER_ID:MSVC>>: -Xcompiler /O2>

        $<$<AND:$<CONFIG:Debug>,$<COMPILE_LANGUAGE:CUDA>,$<CXX_COMPILER_ID:GNU>>: -Xcompiler -g -Xcompiler -O0 -Xcompiler -Wall -Xcompiler -Wextra>
        $<$<AND:$<CONFIG:Release>,$<COMPILE_LANGUAGE:CUDA>,$<CXX_COMPILER_ID:GNU>>: -Xcompiler -O3 -Xcompiler -march=native -Xcompiler -funroll-loops>
)
