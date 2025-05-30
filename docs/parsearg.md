cmake_minimum_required(VERSION 3.10)

project(HelloWorld)

function(my_add_target)
    # 提取第一个参数为 target name
    set(target_name ${ARGV0})

    # 其余参数交给 cmake_parse_arguments
    list(REMOVE_AT ARGV 0)  # 移除第一个参数，剩下的是传给 parse 的
    cmake_parse_arguments(arg "" "TYPE" "SOURCES;DEFINATIONS;INCLUDEDIR;LINKLIBS" ${ARGV})

    if(NOT arg_TYPE)
        message(FATAL_ERROR "my_add_target: TYPE not specified for target ${target_name}")
    endif()

    if("${arg_TYPE}" STREQUAL "STATIC")
        add_library(${target_name} STATIC ${arg_SOURCES})
    elseif("${arg_TYPE}" STREQUAL "EXE")
        add_executable(${target_name} ${arg_SOURCES})
    else()
        message(FATAL_ERROR "my_add_target: Unknown TYPE: ${arg_TYPE}")
    endif()

    if(arg_INCLUDEDIR)
        target_include_directories(${target_name} PRIVATE ${arg_INCLUDEDIR})
    endif()

    if(arg_DEFINATIONS)
        target_compile_definitions(${target_name} PRIVATE ${arg_DEFINATIONS})
    endif()

    if(arg_LINKLIBS)
        target_link_libraries(${target_name} PRIVATE ${arg_LINKLIBS})
    endif()
endfunction()

# 创建库 target
my_add_target(
    foo 
    TYPE STATIC
    SOURCES foo.cpp
)

# 创建可执行程序并链接 foo
my_add_target(
    helloworld
    TYPE EXE
    SOURCES main.cpp 
    DEFINATIONS WORKDIR=${CMAKE_CURRENT_SOURCE_DIR}
    INCLUDEDIR ${CMAKE_CURRENT_SOURCE_DIR}/include
    LINKLIBS foo
)
