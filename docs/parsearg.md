# 💡使用 `cmake_parse_arguments` 封装 `add_library` 和 `add_executable`

在 CMake 项目中，我们经常需要重复编写类似如下代码：

```cmake
add_library(foo STATIC foo.cpp)
target_include_directories(foo PRIVATE include)
target_compile_definitions(foo PRIVATE WORKDIR=/path)
target_link_libraries(helloworld PRIVATE foo)
```

这些调用存在大量模板式重复，可以使用 CMake 的 `function()` + `cmake_parse_arguments()` 封装成一个通用接口。

---

## 🚀 自定义构建函数：`my_add_target`

我们定义一个函数 `my_add_target()`，统一处理目标添加与配置，支持以下参数：

* `TYPE`：目标类型（`STATIC` 或 `EXE`）
* `SOURCES`：源文件
* `DEFINATIONS`：预处理宏定义（如 `-DDEBUG=1`）
* `INCLUDEDIR`：包含目录
* `LINKLIBS`：链接的库/目标

调用示例如下：

```cmake
my_add_target(
    helloworld
    TYPE EXE
    SOURCES main.cpp 
    DEFINATIONS WORKDIR=${CMAKE_CURRENT_SOURCE_DIR}
    INCLUDEDIR ${CMAKE_CURRENT_SOURCE_DIR}/include
    LINKLIBS foo
)
```

---

## 📄 完整 CMakeLists.txt 示例

```cmake
cmake_minimum_required(VERSION 3.10)

project(HelloWorld)

function(my_add_target)
    # 提取第一个参数作为目标名称
    set(target_name ${ARGV0})

    # 移除目标名，传入 cmake_parse_arguments 解析参数
    list(REMOVE_AT ARGV 0)
    cmake_parse_arguments(arg "" "TYPE" "SOURCES;DEFINATIONS;INCLUDEDIR;LINKLIBS" ${ARGV})

    if(NOT arg_TYPE)
        message(FATAL_ERROR "my_add_target: TYPE not specified for target ${target_name}")
    endif()

    # 根据类型调用不同的命令
    if("${arg_TYPE}" STREQUAL "STATIC")
        add_library(${target_name} STATIC ${arg_SOURCES})
    elseif("${arg_TYPE}" STREQUAL "EXE")
        add_executable(${target_name} ${arg_SOURCES})
    else()
        message(FATAL_ERROR "my_add_target: Unknown TYPE: ${arg_TYPE}")
    endif()

    # 设置包含目录
    if(arg_INCLUDEDIR)
        target_include_directories(${target_name} PRIVATE ${arg_INCLUDEDIR})
    endif()

    # 设置宏定义
    if(arg_DEFINATIONS)
        target_compile_definitions(${target_name} PRIVATE ${arg_DEFINATIONS})
    endif()

    # 链接库
    if(arg_LINKLIBS)
        target_link_libraries(${target_name} PRIVATE ${arg_LINKLIBS})
    endif()
endfunction()

# 添加静态库 foo
my_add_target(
    foo 
    TYPE STATIC
    SOURCES foo.cpp
)

# 添加可执行程序 helloworld，并链接 foo
my_add_target(
    helloworld
    TYPE EXE
    SOURCES main.cpp 
    DEFINATIONS WORKDIR=${CMAKE_CURRENT_SOURCE_DIR}
    INCLUDEDIR ${CMAKE_CURRENT_SOURCE_DIR}/include
    LINKLIBS foo
)
```

---

## 🗂️ 项目结构建议

```
your_project/
├── CMakeLists.txt
├── foo.cpp
├── main.cpp
└── include/
    └── foo.h
```

---

## 📚 附录：理解 ARGC / ARGV / ARGN / ARGV\#

在自定义函数中，CMake 提供了一些内建变量来访问参数：

| 名称      | 类型 | 含义                      |
| ------- | -- | ----------------------- |
| `ARGC`  | 数值 | 参数总个数                   |
| `ARGV`  | 列表 | 所有原始参数                  |
| `ARGV#` | 单值 | 第 N 个参数（如 `ARGV0` 是第一个） |
| `ARGN`  | 列表 | 超出最后一个形参的剩余参数           |

### 示例说明

```cmake
function(demo name)
    message("ARGC: ${ARGC}")    # 参数个数
    message("ARGV: ${ARGV}")    # 所有参数
    message("ARGV0: ${ARGV0}")  # 第一个参数
    message("ARGN: ${ARGN}")    # 超过 name 的部分
endfunction()

demo(foo bar baz)
```

输出为：

```
ARGC: 3
ARGV: foo;bar;baz
ARGV0: foo
ARGN: bar;baz
```

---

### ⚠️ 注意：不要越界使用 ARGV\#

使用 `ARGV#` 时如果超出 `ARGC` 范围，会产生 **未定义行为**。应当始终检查：

```cmake
if(ARGC GREATER 2)
    message("Third arg is: ${ARGV2}")
endif()
```


