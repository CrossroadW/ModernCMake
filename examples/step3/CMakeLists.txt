cmake_minimum_required(VERSION 3.20)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

project(MinimalCMakeProject)

add_executable(sdl2_demo main.cpp)

find_package(SDL2)
target_link_libraries(sdl2_demo SDL2::SDL2)