# Compilación cruzada Linux -> Windows x64 (MinGW-w64).
# Esquema de nombres: Variante + compilador + ISA (CamelCase como el repo).
#   make                normal (GCC) + ClangAVX2 (lo que funciona)
#   make normal         WowClient64.exe + Wow64.exe (baseline x86-64/SSE2, para jugar)
#   make avx2           WowClient64-GccAVX2.exe (ROTO: crashea en juego, solo experimentos)
#   make clang-avx2     WowClient64-ClangAVX2.exe + Wow64-ClangAVX2.exe (validado en mundo 2026-10-16)
#   make run            juega la normal con Wine (necesita bin/Win/Data)
#   make run-avx2       juega la GccAVX2 con Wine
#   make run-clang-avx2 juega la ClangAVX2 con Wine
#   make clean          borra los directorios de build (no toca fuentes ni Data)
BUILD_NORMAL := build/mingw-x64
BUILD_AVX2   := build/mingw-x64-avx2
BUILD_CLANG  := build/clang-x64-avx2
DATA_LINK    := bin/Win/Data

CMAKE_FLAGS := --toolchain toolchain-mingw-x64.cmake -G Ninja -DCMAKE_BUILD_TYPE=Release
# AVX2 con GCC: ROTO (crash real en juego 2026-10-16). GCC emite stores ymm
# alineados (vmovdqa) a pila que el ABI Win64/fibras no garantiza (20 sitios:
# achievements, Lua, fuentes...). No lo quitan ni -mpreferred-stack-boundary=4,
# ni -mincoming-stack-boundary=4, ni -fno-tree-vectorize/-fno-tree-slp-vectorize
# (vienen de expansión de copias agregadas, no del vectorizador). Target
# conservado solo para experimentos; NO entra en `all`.
AVX2_FLAGS  := -DCMAKE_C_FLAGS="-mavx2 -fno-strict-aliasing -fwrapv" \
               -DCMAKE_CXX_FLAGS="-mavx2 -fno-strict-aliasing -fwrapv" \
               -DWOWCLIENT_OUTPUT_OVERRIDE=WowClient64-GccAVX2

# Clang no emite los stores ymm alineados en los handlers de red (verificado en
# Packet_SMSG_CRITERIA_UPDATE) y el binario se probó en mundo con Proton el
# 2026-10-16 sin crash. Ojo: aún contiene 16 vmovdqa en rutas frías (tutoriales,
# spellbook, jpeg, freetype): ante un crash similar, avisar con el log.
CLANG_FLAGS := --toolchain toolchain-clang-x64.cmake -G Ninja -DCMAKE_BUILD_TYPE=Release \
               -DCMAKE_C_FLAGS="-mavx2 -fno-strict-aliasing -fwrapv" \
               -DCMAKE_CXX_FLAGS="-mavx2 -fno-strict-aliasing -fwrapv" \
               -DWOWCLIENT_OUTPUT_OVERRIDE=WowClient64-ClangAVX2 \
               -DWOW_OUTPUT_OVERRIDE=Wow64-ClangAVX2
.PHONY: all normal avx2 clang-avx2 configure-normal configure-avx2 configure-clang run run-avx2 run-clang-avx2 check-data clean

all: normal clang-avx2

clang-avx2: configure-clang
	cmake --build $(BUILD_CLANG) --target WowClient Wow --parallel

configure-clang:
	cmake -S . -B $(BUILD_CLANG) $(CLANG_FLAGS)

normal: configure-normal
	cmake --build $(BUILD_NORMAL) --target WowClient Wow --parallel

avx2: configure-avx2
	cmake --build $(BUILD_AVX2) --target WowClient --parallel

configure-normal:
	cmake -S . -B $(BUILD_NORMAL) $(CMAKE_FLAGS)

configure-avx2:
	cmake -S . -B $(BUILD_AVX2) $(CMAKE_FLAGS) $(AVX2_FLAGS)

run: normal check-data
	wine bin/Win/WowClient64.exe

run-avx2: avx2 check-data
	wine bin/Win/WowClient64-GccAVX2.exe

run-clang-avx2: clang-avx2 check-data
	wine bin/Win/WowClient64-ClangAVX2.exe

check-data:
	@test -e $(DATA_LINK) || (echo "Falta $(DATA_LINK): apunta a tus MPQ con 'ln -sfn /ruta/a/WoW/Data $(DATA_LINK)'" && false)

clean:
	rm -rf $(BUILD_NORMAL) $(BUILD_AVX2) $(BUILD_CLANG)
