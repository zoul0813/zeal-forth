cmake_minimum_required(VERSION 3.16)

# Application Version
set(APP_VERSION_MAJOR 0)
set(APP_VERSION_MINOR 1)
set(APP_VERSION_PATCH 1)
set(APP_NAME "Zeal Forth")
set(target_name "forth")

set(CMAKE_VERBOSE_MAKEFILE ON CACHE BOOL "" FORCE)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/debug)

# Ensure the bin directory exists
file(MAKE_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

set(ZOS_TOOLCHAIN z88dk)
include($ENV{ZOS_PATH}/cmake/zos_init.cmake)

project(${target_name} ASM)

file(GLOB ASM_INCLUDES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_LIST_DIR}/include/*.asm"
)


add_executable(${target_name}
    src/main.asm
    src/hshtbl.asm
    src/common.asm
    src/math_8.asm
    src/math_16.asm
    src/dict.asm
    src/data.asm
    src/words.asm
  )
set_source_files_properties(src/main.asm PROPERTIES
    OBJECT_DEPENDS "${ASM_INCLUDES}"
)

target_link_options(${target_name} PRIVATE -v -mz80 -s -l -m -g)
target_link_libraries(${target_name} -L$ENV{ZOS_PATH}/kernel_headers/z88dk-z80asm/lib -lstrutils)
target_include_directories(${target_name} PRIVATE ${CMAKE_CURRENT_LIST_DIR}/include)

set(OUTPUT_BIN "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$<TARGET_FILE_BASE_NAME:${target_name}>_TEXT.bin")
set(FINAL_BIN  "${CMAKE_CURRENT_LIST_DIR}/bin/$<TARGET_FILE_BASE_NAME:${target_name}>")

add_custom_command(
    TARGET ${target_name} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${OUTPUT_BIN}" "${FINAL_BIN}"
    COMMENT "Fixing z88dk output filename"
)

zos_add_outputs(${target_name})
