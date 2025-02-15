# **Qt + CMake (example/step6)**
本章主要介绍 **Qt 的 MOC、RCC、UIC** 在 CMake 中的使用方式。

### **1. RCC（Qt 资源编译器）**
[Qt 资源系统](https://wiki.qt.io/QtResources)  
`rcc`（Qt Resource Compiler）用于 **将二进制资源文件嵌入到应用程序中**，提供了一种跨平台的方法来访问图片、音频等文件。  
**核心作用**：

- 将 **.qrc** 文件转换为 **C++ 代码**，然后嵌入到可执行文件。
- 允许使用 `":/path/to/resource"` 直接访问资源，而不依赖外部文件。
  
### **2. MOC（Meta-Object Compiler，元对象编译器）**
[Qt 元对象编译器](https://doc.qt.io/qt-6/moc.html)  
`moc` 主要用于 **处理 Qt 的元对象系统**，例如：

- **信号与槽（signals & slots）**
- **动态属性（Dynamic Properties）**
- **运行时类型信息（RTTI）**

### **3. UIC（UI Compiler，用户界面编译器）**
[Qt UIC ](https://doc.qt.io/qt-6/uic.html)  
`uic` 用于 **将 .ui 文件（Qt Designer 设计的界面）转换为 C++ 代码**，并生成 `ui_*.h` 头文件。


# CMake 示例
```cmake
cmake_minimum_required(VERSION 3.20)

project(qt_cmake LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)  # 自动处理 UI 文件
set(CMAKE_AUTOMOC ON)  # 自动处理 Q_OBJECT 相关 MOC 代码
set(CMAKE_AUTORCC ON)  # 自动处理 QRC 资源文件

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)

set(PROJECT_SOURCES
        main.cpp
        mainwindow.cpp
        mainwindow.h # 头文件也是必要的
        mainwindow.ui # ui也能处理
        resources.qrc  # 添加 QRC 资源文件
)

add_executable(untitled1
            ${PROJECT_SOURCES}
        )

target_link_libraries(untitled1 PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)
```

```cpp
// mainwindow.h
#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE

namespace Ui {
class MainWindow;
}

QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private:
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_H
// <<mainwindow.h


// mainwindow.cpp
#include "mainwindow.h"
#include "ajfioajifojaio/ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent),
      ui(new Ui::MainWindow) {
    ui->setupUi(this);
}

MainWindow::~MainWindow() {
    delete ui;
}
// <<mainwindow.cpp
```

# 运行
```bash
rm build -rf && 
cmake -S . -B build -G Ninja \
-DCMAKE_PREFIX_PATH=/home/awe/Qt/6.8.1/gcc_64 &&
cmake --build build -j 4
$ pwd 
<CMAKE_BINARY_DIR>/build/<target>_autogen/ # moc uic rcc 等生成的文件
$ tree -L 3 .
..
├── EWIEGA46WW
│   ├── moc_mainwindow.cpp # 由moc生成，根据mainwindow.h中QOBJECT宏生成的moc实现代码，会被链接到target
│   └── moc_mainwindow.cpp.d # mainwindow.h的依赖文件(.h) 每个#include 都会产生一系列依赖
├── include
│   └── ajfioajifojaio # 由uic生成，根据匹配规则(#include "ajfioajifojaio/ui_mainwindow.h")生成的对应ui.h
│       └── ui_mainwindow.h

```
## 案例讲解
`CMAKE_AUTOUIC`、 
`CMAKE_AUTOMOC`、
`CMAKE_AUTORCC`
这三个`CMAKE_<cmake-property>` 
影响后面的每一个target(如add_executable、add_library创建的目标)
也就是全局开关；

除此之外也有针对每一个target单独的属性(可以通过set_target_property设置)：
[AUTOMOC](https://cmake.org/cmake/help/latest/prop_tgt/AUTOUIC.html) [AUTOUIC](https://cmake.org/cmake/help/latest/prop_tgt/AUTOMOC.html) [AUTORCC](https://cmake.org/cmake/help/latest/prop_tgt/AUTORCC.html#prop_tgt:AUTORCC)他们都是cmake中的一个[属性](https://cmake.org/cmake/help/latest/manual/cmake-properties.7.html#id1)
 > 每个对象可以附加属性，属性是附加到特定对象的键值对

#### 属性AUTOMOC: 
决定是否检查目标的c++文件(QOBJECT宏)是否需要moc,默认不会链接.cpp文件生成的moc文件,如果需要可以`#include <base>.moc"` 如：`#include "main.moc` 是不是有的地方见过呢🤔<br>
其实就是自动扫描mainwindow.h中QOBJECT宏，生成moc实现文件moc_mainwindow.cpp，所以.h文件也要add_executable。
> 此外CLion、Visual Studio 需要 `.h` 文件用于代码分析，因此非Qt项目的 `.h` 需要加入 `add_executable()`。


#### 属性AUTOUIC: 
决定是否检查目标中的 C++ 文件以确定它们是否需要运行 uic，并创建规则以在适当的时间执行 uic。
> 实际就是控制`.ui` 到 `ui_*.h`的转换

**ui文件查找规则：**

> cmake会找到与C++代码中匹配`<path/>ui_<basename>.h`的 #include 指令，如果存在 .ui 文件，则将执行 uic 以生成相应的文件(如上面的`ajfioajifojaio/ui_mainwindow.h`)。
.ui 搜索根据以下匹配规则:

`<cmake_source_dir>/<basename>.ui` 

`<cmake_source_dir>/<path/><basename>.ui`  **推荐** 

`<AUTOUIC_SEARCH_PATHS>/<basename>.ui` 
> **AUTOUIC_SEARCH_PATHS**是自定义的cmake变量

`<AUTOUIC_SEARCH_PATHS>/<path/><basename>.ui`

**最佳实践**：UI 文件应与 `.h/.cpp` 一起放置：
```bash
$ tree view/
view/
├── mainwindow.cpp
├── mainwindow.h
└── mainwindow.ui
```
#### AUTORCC:
决定是否 **自动运行 `rcc`**，将 `.qrc` 文件转换为 C++ 代码。
**示例：**
```xml
<RCC>
    <qresource prefix="/">
        <file>icons/logo.png</file>
        <file>myapp/main.qml</file>
    </qresource>
</RCC>
```
**访问方式：**
```cpp
QPixmap pix(":/icons/logo.png"); 

QQmlApplicationEngine engine;
//对于要求QUrl的参数使用"qrc:/icons/logo.png"
engine.load(QUrl("qrc:/myapp/main.qml"));
```
通常不必在意(例外是动态库静态库,参见[wiki](https://wiki.qt.io/QtResources))。
