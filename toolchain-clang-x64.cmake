# Cross-compila wowdecomp (Windows x64) desde Linux con Clang/LLVM + MinGW-w64.
# Clang no emite stores ymm alineados a pila (causa del crash AVX2 con GCC),
# por eso es el compilador recomendado para builds con -mavx2.
# Uso:
#   cmake -S . -B build/clang-x64-avx2 --toolchain toolchain-clang-x64.cmake -G Ninja -DCMAKE_BUILD_TYPE=Release
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# Target mingw-w64 para headers/libs de Windows (igual que GCC). Se usa
# COMPILER_TARGET (no FLAGS_INIT) para que aplique desde el check del
# compilador y CMake detecte el triple mingw (variable MINGW).
set(CMAKE_C_COMPILER_TARGET x86_64-w64-mingw32)
set(CMAKE_CXX_COMPILER_TARGET x86_64-w64-mingw32)

set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
