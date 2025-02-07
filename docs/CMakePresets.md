# CMakePresets.json
CMake 用户经常面临的一个问题如何其他人共享配置(可能需要写run.sh run.ps1 run.bat)。  
自CMake 3.19起支持用json配置并运行项目，CMake 主要支持两个文件CMakePresets.json和CMakeUserPresets.json(要求位于项目根目录,使用preset构建则必须至少存在一个preset）。

> 两个preset.json没有内容差异。CMakePresets.json是面向所有用户的(理应提交到git)，CMakeUserPresets.json应添加到.gitignore

## 具体案例
### 准备源代码与配置文件
目录结构如下：
```txt
$ tree 
.
├── CMakeLists.txt
├── CMakePresets.json
└── main.cpp
```
主要看CMakePresets.json(example/step4)大概如下：
```json
{
  "version": 9,
  "configurePresets": [
    {
      "name": "config-default",
      "description": "Default configuration",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/default",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug",
       "CMAKE_INSTALL_PREFIX": "${sourceDir}/install"
      }
    },
    {
      "name": "config-release",
      "description": "Release configuration",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/release",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Release",
        "CMAKE_INSTALL_PREFIX": "${sourceDir}/release-install"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "build-default",
      "configurePreset": "config-default",
      "jobs": 8
    },
    {
      "name": "build-release",
      "configurePreset": "config-release",
      "jobs": 8
    }
  ]
}
```
### 运行:
按照通常的cmake项目构建步骤，先配置，后构建。
```bash
$ cmake --list-presets # 输出看是否cmakeprest格式无误
Available configure presets:

  "config-default"
  "config-release"
$ cmake --preset config-default # 选择配置`config-default`,生成"binaryDir"中指定的目录build/default

$ cmake --build --list-presets # 输出可用的build presets(可选)
Available build presets:

  "build-default"
  "build-release"

$ cmake --build --preset build-default # 执行构建,生成build/default/cmake_preset可执行程序
```

## CMakePresets.json 具体参数:
这里的CMakePresets.json参数非常简单，是完全可以对应到具体的cmake命令上。  
配置阶段参数:
    
    generator对应-G Ninja
    binaryDir对应-B ./build/default
    CMAKE_BUILD_TYPE对应 -D CMAKE_BUILD_TYPE=Debug
    CMAKE_INSTALL_PREFIX对应 -D CMAKE_INSTALL_PREFIX=./install
构建阶段参数：

    jobs对应 -j/--parallel 8


## cmakepreset复用
CMakeUserPresets.json可以使用文件的include字段包含其他文件。这些文件所包含的文件还可以包含其他文件。如果CMakePresets.json和 CMakeUserPresets.json都存在， CMakeUserPresets.json 在格式的所有版本中隐式包含CMakePresets.json ，即使没有include字段。
具体例子：  
例子根据上面的案例，新增一个CMakeUserPresets.json
```json
{
    "version": 9,
    "configurePresets": [
        {
            "inherits": "config-default",
            "name": "myconfig",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug",
                "CMAKE_INSTALL_PREFIX": "${sourceDir}/myinstall"
            }
        }
    ]
}
```
```bash
$ cmake --list-presets # CMakeUserPresets.json隐式包含CMakePresets.json
Available configure presets:

  "myconfig"
  "config-default"
  "config-release"
  
$ cmake --build --list-presets
Available build presets:

  "build-default"
  "build-release"  
```

<details>
<summary>完整的 CMakeLists.txt 和 main.cpp 示例代码(examples/step4)</summary>

<pre><code class="cmake">
cmake_minimum_required(VERSION 3.20)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# 创建可执行文件
add_executable(find_lib_demo main.cpp)

# 查找 SDL2 库
find_package(SDL2)

# 给find_lib_demo这个目标链接 SDL2 库
target_link_libraries(find_lib_demo SDL2::SDL2)
</code></pre>

<pre><code class="cpp">
#include &lt;SDL.h&gt;
#include &lt;iostream&gt;

int main(int argc, char* args[]) {
    // 初始化SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        return -1;
    }

    // 创建窗口
    SDL_Window* window = SDL_CreateWindow("SDL Demo", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, SDL_WINDOW_SHOWN);
    if (window == nullptr) {
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return -1;
    }

    // 创建渲染器
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (renderer == nullptr) {
        std::cerr << "Renderer could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    // 设置绘制颜色为蓝色
    SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);

    // 清除屏幕
    SDL_RenderClear(renderer);

    // 绘制一个矩形
    SDL_Rect rect = {100, 100, 200, 150};
    SDL_RenderFillRect(renderer, &rect);

    // 更新屏幕显示
    SDL_RenderPresent(renderer);

    // 事件处理
    bool quit = false;
    SDL_Event e;
    while (!quit) {
        while (SDL_PollEvent(&e) != 0) {
            if (e.type == SDL_QUIT) {
                quit = true;
            }
        }
    }

    // 释放资源并退出
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
</code></pre>

</details>

下一章[设置目标属性](/设置目标属性/)