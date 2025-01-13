# 现代CMake的核心概念

<a id="coreconcept"></a>
## 目标:
目标（Target）是现代CMake最核心的概念。目标代表了由CMake构建的可执行文件、库和自定义命令。每个add_library、add_executable和add_custom_target命令都会创建一个目标。  
**特点**  
- 全局作用域：可在项目中任何地方使用。
- 自动扩展名：CMake根据平台自动决定扩展名（如Windows下可执行文件为.exe）。
- 动态查询修改：可用set_target_properties和get_target_property动态更新目标属性。

可执行文件（Executable）：通过add_executable命令创建。例如，add_executable(my_app main.cpp)会创建一个名为my_app的可执行文件，其源文件为main.cpp。

库（Library）：通过add_library命令创建。例如，add_library(foo STATIC foo1.c foo2.c)会创建一个名为foo的静态库，其源文件为foo1.c和foo2.c。

自定义目标（Custom Target）：通过add_custom_target命令创建，用于执行自定义的构建任务。

## TODO


下一章[最小构建.md](最小构建.md)