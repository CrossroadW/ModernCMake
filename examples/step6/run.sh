rm build -rf && 
cmake -S . -B build -G Ninja \
-DCMAKE_PREFIX_PATH=/home/awe/Qt/6.8.1/gcc_64 &&
cmake --build build -j 4