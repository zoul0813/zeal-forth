cmake_minimum_required(VERSION 3.16)

# Application Version
set(APP_VERSION_MAJOR 0)
set(APP_VERSION_MINOR 1)
set(APP_VERSION_PATCH 1)
set(APP_NAME "Zeal Forth")
set(target_name "forth")

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin)

# Ensure the bin directory exists
file(MAKE_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

set(ZOS_TOOLCHAIN z88dk)
include($ENV{ZOS_PATH}/cmake/zos_init.cmake)

project(${target_name} ASM)
add_executable(${target_name}
    src/main.asm
)

target_link_options(${target_name} PRIVATE -s -l -m -g)
target_link_libraries(${target_name} -L$ENV{ZOS_PATH}/kernel_headers/z88dk-z80asm/lib -lstrutils)

zos_add_outputs(${target_name})
