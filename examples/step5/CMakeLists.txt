cmake_minimum_required(VERSION 3.20)

project(project1)

add_executable(main test.cpp)
add_library(foo SHARED foo.cpp)
add_library(foo-static STATIC foo.cpp)

set_target_properties(foo
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ../target/lib/
    LIBRARY_OUTPUT_NAME hello_foo
    SUFFIX .so.1
)

set_target_properties(foo-static
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ../target/lib/
    LIBRARY_OUTPUT_NAME hello_foo-static
    SUFFIX .lib
)

set_target_properties(main
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ../target/bin
    RUNTIME_OUTPUT_NAME project_main
    SUFFIX .exe
)
