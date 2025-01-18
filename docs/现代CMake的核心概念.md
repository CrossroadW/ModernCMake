# 现代CMake的核心概念

<a id="coreconcept"></a>
### 目标
**`目标（Target）`**是现代CMake最核心的概念。目标代表了由CMake构建的可执行文件、库和自定义命令。每个add_library、add_executable和add_custom_target命令都会创建一个目标。
每个对象可以附加属性，属性是附加到特定对象的键值对。  
#### 目标的主要特点
- 全局作用域：一旦创建，可在项目中任何地方引用。
- 自动扩展名：CMake根据平台自动决定扩展名（如Windows下可执行文件为.exe）。
- 动态查询修改：可用set_target_properties和get_target_property动态更新目标属性。

可执行文件（Executable）：

    通过add_executable命令创建。例如，add_executable(my_app main.cpp)会创建一个名为my_app的可执行文件，其源文件为main.cpp。

库（Library）：

    通过add_library命令创建。例如，add_library(foo STATIC foo1.c foo2.c)会创建一个名为foo的静态库，其源文件为foo1.c和foo2.c。

自定义目标（Custom Target）：

    通过add_custom_target命令创建，用于执行自定义的构建任务。

## 使用要求(Usage Requirements)
在 CMake 中，`使用要求`（Usage Requirements）也可以被称作“传播机制”，它指的是目标在构建时的要求，以及这些要求如何传播给其他链接到该目标的目标。可供选择的有`PUBLIC 、 PRIVATE 和 INTERFACE`。
### 具体例子:
该例子表示任何链接(target_link_libraries)到目标 foo 的目标都会自动将 foo 的源代码目录作为包含目录，包括自身。
```cmake
add_library(foo foo.cpp)
target_include_directories(foo PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
```
对于另外两种`使用要求`:

- 使用 PRIVATE 时，只有 foo 目标本身`会`将源代码目录作为包含目录。其他链接到 foo 的目标`不会继承`这个包含目录设置。  
- 使用 INTERFACE 时，foo 本身本身`不会`将源代码目录作为包含目录，而是一个仅供链接的目标。但是，其他链接到 foo 的目标都会自动继承 foo 设置的包含目录。


下一章[最小构建.md](最小构建.md)