# 设置 CMake 的最低版本要求
cmake_minimum_required(VERSION 3.10)

# 定义项目名称
project(MinimalCMakeProject)

# 添加一个可执行目标
add_executable(hello_cmake main.cpp)