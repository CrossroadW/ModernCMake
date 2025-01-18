# find_package案例
这一章是一个 **`find_package` 案例** 的案例，大部分初学者会经常因为这个命令找不到库而报错(明明别人能跑🤔)：  



### 1. **find_package基础案例**
示例：`SDL2` 包并构建一个sdl2_demo。

```cmake
cmake_minimum_required(VERSION 3.20)

# 生成<build_dir>/compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

# SDL2_DIR 必须指定到.cmake所在路径 
set(SDL2_DIR /home/awe/Desktop/clone/learn_SDL2/3rd/install/lib64/cmake/SDL2)

# SDL2_ROOT 指定到install既可，`lib64/cmake/SDL2`会自动匹配
# set(SDL2_ROOT /home/awe/Desktop/clone/learn_SDL2/3rd/install)

# CMAKE_PREFIX_PATH同SDL2_ROOT都按照前缀搜索规则模糊搜索
# set(CMAKE_PREFIX_PATH /home/awe/Desktop/clone/learn_SDL2/3rd/install)
project(MinimalCMakeProject)

add_executable(sdl2_demo main.cpp)

# 查找SDL2库
find_package(SDL2)
target_link_libraries(sdl2_demo SDL2::SDL2)
```


### 2. find_package详解
#### 默认搜索模式
`find_package` 基本语法：  
`find_package(<PackageName> [<version>] [REQUIRED] [COMPONENTS <components>...])`

`find_package` 找到一个包（通常由项目外部的东西提供），并加载其这个包。
`find_package` 该命令有几种搜索包的模式,默认先按照模块模式搜索，后按照配置模式搜索：

- 模块模式（Module mode相对较老，兼容老库）：  
在此模式下，CMake 搜索名为`Find<PackageName>.cmake`的文件，首先在`CMAKE_MODULE_PATH`中列出的位置中查找，如果找到该文件，则由 CMake 读取并处理该文件。
- 配置模式（Config Mode）: 
     在此模式下，CMake 搜索名为的文件 &lt;lowercasePackageName&gt;-config.cmake 、&lt;PackageName&gt;Config.cmake，如果指定了<version>选项还会先查找 &lt;lowercasePackageName&gt;-config-version.cmake、&lt;PackageName&gt;ConfigVersion.cmake。  
#### 指定搜索模式
`find_package`支持通过`MODULE|CONFIG`选项来选择某一种搜索模式
`find_package(<PackageName> [...] [MODULE|CONFIG]`    

`find_package`查找会根据以下变量查找上文列出的.cmake文件(常用的)：
CMAKE_PREFIX_PATH、&lt;PackageName&gt;_DIR、&lt;PackageName&gt;_ROOT、CMAKE_INSTALL_PREFIX(不推荐)、环境变量PATH。
#### 根据前缀搜索
一般是设置**`CMAKE_PREFIX_PATH`** ，主要靠它作为搜索**`前缀`**,其他变量必须指定到.cmake文件所在目录；不过对于&lt;PackageName&gt;_DIR是必须指定到.cmake所在目录的。
搜索**`前缀`**的搜索规则([完整搜索规则参考](https://cmake.org/cmake/help/latest/command/find_package.html#config-mode-search-procedure))：
适用于unix系的约定:
```txt
<prefix>/(lib/<arch>|lib*|share)/cmake/<name>*/

<prefix>/(lib/<arch>|lib*|share)/<name>*/

<prefix>/(lib/<arch>|lib*|share)/<name>*/(cmake|CMake)/
```
适用于unix/windows的约定：
```txt
<prefix>/<name>*/(lib/<arch>|lib*|share)/cmake/<name>*/

<prefix>/<name>*/(lib/<arch>|lib*|share)/<name>*/

<prefix>/<name>*/(lib/<arch>|lib*|share)/<name>*/(cmake|CMake)/
```
适用于mac的约定：
```txt
<prefix>/<name>.framework/Resources/CMake/

<prefix>/<name>.framework/Versions/*/Resources/

<prefix>/<name>.framework/Versions/*/Resources/CMake/
```



---


<details>
<summary>完整的 CMakeLists.txt 和 main.cpp 示例代码(examples/step3)</summary>

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
