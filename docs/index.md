# 现代CMake教程
C++的复杂系统构建几乎都要用到CMake,尽管国内先进的CMake系统教程有很多，但是很多缺少专业性，不够严谨，所以我们需要一个现代的、准确的CMake教程。

![cmake](img/cmakerate.png)

## 什么是CMake？
[CMake](https://cmake.org/) 是一个跨平台的开源[构建系统](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#introduction)生成器(也称为[元构建工具](https://en.wikipedia.org/wiki/List_of_build_automation_software))，可以给其他构建工具(Visual Studio、Make、Ninja、Xcode)生成配置文件(project.sln、build.ninja、Makefile)。

从根本来讲构建系统就是将源代码转换(.cpp)为二进制文件(.exe|.lib|.dll)
![public/Single_Source_Build.png](img/Single_Source_Build.png)

## 为什么不直接使用编译器？
最简单的的当然是直接使用命令行调用gcc、cl.exe、clang++等工具，但是一旦代码库复杂起来，就不可能只靠命令行。

单文件的情况下编译只需要一行
```bash
g++ -o main.exe main.cpp
```

多个文件的话就会复杂一点:
```bash
# examples/step1
$ tree
├── foo.cpp
├── foo.h
├── main.cpp
$ g++ -o foo.o -c foo.cpp
$ g++ -o main.o -c main.cpp 
$ g++ -o step1 main.o foo.o
$ ./step1 
43
```
而且当我们需要构建debug、release版本并且需要手动链接库的时候，命令行就不能满足我们的需求了。

下一章[环境搭建](环境搭建.md)
## 参考文档
https://cliutils.gitlab.io/modern-cmake/README.html  
https://cmake.org/cmake/help/v3.20/index.html      
https://modern-cmake-cn.github.io/Modern-CMake-zh_CN/
https://xiazuomo.gitbook.io/modern-cmake-chinese/introduction
https://ukabuer.me/blog/more-modern-cmake/
https://www.bilibili.com/video/BV1Mw411M761/
https://www.bilibili.com/video/BV16P4y1g7MH
https://crascit.com/professional-cmake/
https://zh.wikipedia.org/wiki/CMake
https://github.com/Mq-b/CXX_LIB