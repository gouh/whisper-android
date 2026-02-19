cmake_minimum_required(VERSION 3.10)
project(whisper_android)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -DNDEBUG -fPIC")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -DNDEBUG -fPIC")

# Paths
set(WHISPER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/..)
set(GGML_DIR ${WHISPER_DIR}/ggml)

# GGML library
add_library(ggml STATIC
    ${GGML_DIR}/src/ggml.c
    ${GGML_DIR}/src/ggml-alloc.c
    ${GGML_DIR}/src/ggml-backend.cpp
    ${GGML_DIR}/src/ggml-quants.c
    ${GGML_DIR}/src/ggml-cpu/ggml-cpu.c
)

target_include_directories(ggml PUBLIC
    ${GGML_DIR}/include
    ${GGML_DIR}/src
)

target_compile_definitions(ggml PRIVATE
    GGML_USE_CPU
)

# Whisper library
add_library(whisper STATIC
    ${WHISPER_DIR}/src/whisper.cpp
)

target_include_directories(whisper PUBLIC
    ${WHISPER_DIR}/include
    ${GGML_DIR}/include
)

target_link_libraries(whisper ggml)

# JNI wrapper
add_library(whisper_android SHARED
    whisper_android.cpp
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
