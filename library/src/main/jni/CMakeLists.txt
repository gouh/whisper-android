cmake_minimum_required(VERSION 3.10)
project(whisper_android C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_C_STANDARD 11)

# Paths
set(GGML_DIR ${CMAKE_CURRENT_SOURCE_DIR}/ggml)
set(WHISPER_DIR ${CMAKE_CURRENT_SOURCE_DIR})

# GGML
file(GLOB_RECURSE GGML_CPU_SOURCES
    ${GGML_DIR}/src/ggml-cpu/*.c
    ${GGML_DIR}/src/ggml-cpu/*.cpp
)

# Exclude incompatible architectures
list(FILTER GGML_CPU_SOURCES EXCLUDE REGEX ".*/spacemit/.*")
list(FILTER GGML_CPU_SOURCES EXCLUDE REGEX ".*/kleidiai/.*")
list(FILTER GGML_CPU_SOURCES EXCLUDE REGEX ".*/llamafile/.*")

add_library(ggml STATIC
    ${GGML_DIR}/src/ggml.c
    ${GGML_DIR}/src/ggml-alloc.c
    ${GGML_DIR}/src/ggml-backend.cpp
    ${GGML_DIR}/src/ggml-backend-reg.cpp
    ${GGML_DIR}/src/ggml-backend-dl.cpp
    ${GGML_DIR}/src/ggml-threading.cpp
    ${GGML_DIR}/src/ggml-quants.c
    ${GGML_CPU_SOURCES}
)

target_include_directories(ggml PUBLIC
    ${GGML_DIR}/include
    ${GGML_DIR}/src
    ${GGML_DIR}/src/ggml-cpu
)

target_compile_definitions(ggml PRIVATE 
    GGML_USE_CPU
    GGML_VERSION="0.1.0"
    GGML_COMMIT="unknown"
)
target_compile_options(ggml PRIVATE -O3 -fPIC -pthread)

# Whisper
add_library(whisper STATIC
    ${WHISPER_DIR}/src/whisper.cpp
)

target_include_directories(whisper PUBLIC
    ${WHISPER_DIR}/include
    ${GGML_DIR}/include
)

target_compile_definitions(whisper PRIVATE WHISPER_VERSION="1.5.4")
target_link_libraries(whisper ggml)
target_compile_options(whisper PRIVATE -O3 -fPIC)

# JNI
add_library(whisper_android SHARED
    ${WHISPER_DIR}/whisper/whisper_android.cpp
)

target_include_directories(whisper_android PRIVATE
    ${WHISPER_DIR}/include
    ${GGML_DIR}/include
)

target_link_libraries(whisper_android
    whisper
    ggml
    android
    log
)
