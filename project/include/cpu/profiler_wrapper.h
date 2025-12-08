//
// Created by chefxx on 8.12.2025.
//

#ifndef SUDOKU_PROFILER_WRAPPER_H
#define SUDOKU_PROFILER_WRAPPER_H

#include <nvtx3/nvToolsExt.h>
#include <spdlog/spdlog.h>

struct ProfileRange {
    explicit ProfileRange(const char* name) {
        nvtxRangePushA(name);
    }
    ~ProfileRange() {
        nvtxRangePop();
    }
};

#define PROFILE_SCOPE(name) ProfileRange p(name)


#ifdef NDEBUG
    #define CUDA_CHECK_KERNEL(message)
    #define CUDA_SYNC_CHECK(message)
#else
    #define CUDA_CHECK_KERNEL(message) getLastCudaError(fmt::format("Kernel {} failed..", (message))
    #define CUDA_SYNC_CHECK(message) checkCudaErrors(cudaDeviceSynchronize())
#endif

#endif // SUDOKU_PROFILER_WRAPPER_H
