@echo off
rem One-command build for wowdecomp (x64 only; Win32 out of scope).
rem Flavors:
rem   classic - README build: VS generator + MSVC, no extra flags.
rem   llvm    - VS generator + ClangCL toolset (uses link.exe, so the
rem             MSVC-isms in CMake still work) with /arch:AVX2.
rem Usage:
rem   build.bat [classic^|llvm] [Release^|Debug] [target] [reconfigure]
rem   build.bat clean [classic^|llvm^|all]
rem   build.bat help                  - also the default with no arguments
rem Examples:
rem   build.bat                 -> classic / Release / WowClient
rem   build.bat llvm            -> llvm / Release / WowClient
rem   build.bat llvm Debug Wow  -> llvm / Debug / target Wow
rem Prerequisite for llvm: VS component "C++ Clang Compiler for Windows"
rem   (clang-cl.exe under VC\Tools\Llvm).
setlocal

set "SRC=%~dp0"
set "CLASSIC_DIR=%SRC%build\x64"
set "LLVM_DIR=%SRC%build\x64-llvm"
set "FLAVOR=classic"
set "FLAVOR_GIVEN=0"
set "CONFIG=Release"
set "TARGET=WowClient"
set "FORCE=0"
set "ACTION=build"

if "%~1"=="" set "ACTION=help"
:parse
if "%~1"=="" goto parsed
if /i "%~1"=="classic" ( set "FLAVOR=classic" & set "FLAVOR_GIVEN=1" & shift & goto parse )
if /i "%~1"=="llvm" ( set "FLAVOR=llvm" & set "FLAVOR_GIVEN=1" & shift & goto parse )
if /i "%~1"=="Debug" ( set "CONFIG=Debug" & shift & goto parse )
if /i "%~1"=="Release" ( set "CONFIG=Release" & shift & goto parse )
if /i "%~1"=="clean" ( set "ACTION=clean" & shift & goto parse )
if /i "%~1"=="reconfigure" ( set "FORCE=1" & shift & goto parse )
if /i "%~1"=="help" ( set "ACTION=help" & shift & goto parse )
if /i "%~1"=="-h" ( set "ACTION=help" & shift & goto parse )
if /i "%~1"=="--help" ( set "ACTION=help" & shift & goto parse )
if /i "%~1"=="all" ( shift & goto parse )
set "TARGET=%~1"
shift
goto parse
:parsed

if /i "%ACTION%"=="help" (
  echo Usage:
  echo   build.bat [flavor] [config] [target] [reconfigure]
  echo   build.bat clean [classic^|llvm^|all]
  echo   build.bat help
  echo.
  echo Flavors:
  echo   classic  README build: VS + MSVC, no extra flags. Dir build\x64.
  echo   llvm     VS + ClangCL -T ClangCL with /arch:AVX2. Dir build\x64-llvm.
  echo            Needs VS component C++ Clang Compiler for Windows.
  echo.
  echo Configs: Release [default], Debug.
  echo.
  echo Targets: WowClient [default], Wow, MapViewer, M2Viewer, GxTest,
  echo          MpqTest, BlpTest, DbcTest, AssetCheck.
  echo.
  echo Other:
  echo   reconfigure  force a fresh configure. Needed after flag changes.
  echo   clean        remove build dirs. clean llvm removes only build\x64-llvm.
  echo   help         show this help. Also shown with no arguments.
  echo.
  echo Examples:
  echo   build.bat                 show this help
  echo   build.bat classic         build WowClient Release with MSVC
  echo   build.bat llvm            build WowClient Release with ClangCL + AVX2
  echo   build.bat llvm Debug Wow  build target Wow, Debug, llvm flavor
  echo.
  echo Output: EXE lands in bin\Win as WowClient64.exe or Wow64.exe.
  exit /b 0
)

if /i "%ACTION%"=="clean" (
  if "%FLAVOR_GIVEN%"=="0" (
    if exist "%CLASSIC_DIR%" rmdir /s /q "%CLASSIC_DIR%"
    if exist "%LLVM_DIR%" rmdir /s /q "%LLVM_DIR%"
    echo Cleaned %CLASSIC_DIR% and %LLVM_DIR%
  ) else if /i "%FLAVOR%"=="llvm" (
    if exist "%LLVM_DIR%" rmdir /s /q "%LLVM_DIR%"
    echo Cleaned %LLVM_DIR%
  ) else (
    if exist "%CLASSIC_DIR%" rmdir /s /q "%CLASSIC_DIR%"
    echo Cleaned %CLASSIC_DIR%
  )
  exit /b 0
)

if /i "%FLAVOR%"=="llvm" ( set "BLD=%LLVM_DIR%" ) else ( set "BLD=%CLASSIC_DIR%" )

rem Pick generator: newest installed VS first (vswhere ships with VS).
set "VER=unknown"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
  for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -property installationVersion 2^>nul`) do set "VER=%%i"
  echo Detected Visual Studio: %VER%
)
rem Default to VS 2026 (v18); fall back to 2022 (v17).
if exist "%ProgramFiles%\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.com" (
  set "GEN=Visual Studio 18 2026"
) else (
  set "GEN=Visual Studio 17 2022"
)

rem Configure when forced, missing, or from another generator.
rem Separate dirs per flavor, so the toolset cannot clash.
set "NEED_CONFIGURE=1"
if "%FORCE%"=="0" (
  if exist "%BLD%\CMakeCache.txt" (
    findstr /c:"CMAKE_GENERATOR:INTERNAL=%GEN%" "%BLD%\CMakeCache.txt" >nul 2>&1
    if not errorlevel 1 set "NEED_CONFIGURE=0"
  )
)
if "%NEED_CONFIGURE%"=="0" (
  echo Configure skipped for %FLAVOR%: already uses "%GEN%". Add "reconfigure" to force.
) else (
  if exist "%BLD%" rmdir /s /q "%BLD%"
  if /i "%FLAVOR%"=="llvm" (
    echo Configuring llvm with "%GEN%" -T ClangCL /arch:AVX2 -Wno-register -Wno-c++11-narrowing /EHsc ...
    cmake -S "%SRC%." -B "%BLD%" -G "%GEN%" -A x64 -T ClangCL "-DCMAKE_C_FLAGS=/arch:AVX2 -Wno-register -Wno-c++11-narrowing" "-DCMAKE_CXX_FLAGS=/arch:AVX2 -Wno-register -Wno-c++11-narrowing /EHsc"
  ) else (
    echo Configuring classic with "%GEN%" ...
    cmake -S "%SRC%." -B "%BLD%" -G "%GEN%" -A x64
  )
  if errorlevel 1 exit /b 1
)

echo Building %TARGET% (%CONFIG% ^| %FLAVOR%) ...
cmake --build "%BLD%" --config %CONFIG% --target %TARGET% --parallel
