# ------------------------------------------------------------------------------ #
#                                Project setup                                   #
# ------------------------------------------------------------------------------ #

cmake_minimum_required(VERSION 3.30)
set(PROJECT_NAME "sudoku")

set(MAIN ${PROJECT_NAME})
set(TEST ${PROJECT_NAME}_test)
set(CUDA_LIB ${PROJECT_NAME}_lib)

project(${PROJECT_NAME} LANGUAGES C CXX CUDA)

set(PROJECT_VERSION "1.0")
set(PROJECT_AUTHOR "Mateusz Mikiciuk")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

find_package(CUDAToolkit REQUIRED)

# enable linking static libs to project
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ------------------------------------------------------------------------------ #
#                                  Load dirs                                     #
# ------------------------------------------------------------------------------ #

add_subdirectory(project)
add_subdirectory(dependencies)
add_subdirectory(tests)
enable_testing()