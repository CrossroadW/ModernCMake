cmake_minimum_required(VERSION 3.20)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# set(SDL2_DIR /home/awe/Desktop/clone/learn_SDL2/3rd/install/lib64/cmake/SDL2)

# set(SDL2_ROOT /home/awe/Desktop/clone/learn_SDL2/3rd/install)

set(CMAKE_PREFIX_PATH /home/awe/Desktop/clone/learn_SDL2/3rd/install/lib64/cmake/SDL2)

project(MinimalCMakeProject)

add_executable(sdl2_demo main.cpp)

find_package(SDL2)
target_link_libraries(sdl2_demo SDL2::SDL2)