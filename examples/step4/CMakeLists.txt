cmake_minimum_required(VERSION 3.20)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

project(cmake_preset)

add_executable(cmake_preset main.cpp)

find_package(SDL2)
target_link_libraries(cmake_preset SDL2::SDL2)