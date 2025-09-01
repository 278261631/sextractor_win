@echo off
echo Building SExtractor for Windows...

REM Set paths for MSYS2 MinGW64 and CMake
set MINGW_PATH=C:\msys64\mingw64
set CMAKE_PATH=C:\CMake
set PATH=%MINGW_PATH%\bin;%CMAKE_PATH%\bin;%PATH%

REM Check if required tools exist
echo Checking for required tools...
where gcc >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: GCC not found. Please ensure MSYS2 MinGW64 is installed at %MINGW_PATH%
    pause
    exit /b 1
)

where cmake >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: CMake not found. Please ensure CMake is installed at %CMAKE_PATH%
    pause
    exit /b 1
)

echo Found GCC and CMake.

REM Create build directory
if not exist build mkdir build
cd build

REM Configure with CMake
echo Configuring with CMake...
cmake -G "MinGW Makefiles" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_C_COMPILER=gcc ^
      -DCMAKE_INSTALL_PREFIX=../install ^
      ..

if %errorlevel% neq 0 (
    echo Error: CMake configuration failed
    pause
    exit /b 1
)

REM Build the project
echo Building...
cmake --build . --config Release

if %errorlevel% neq 0 (
    echo Error: Build failed
    pause
    exit /b 1
)

echo Build completed successfully!
echo Executables are in the build directory.

REM Optional: Install
echo.
set /p install_choice="Do you want to install to ../install directory? (y/n): "
if /i "%install_choice%"=="y" (
    cmake --install .
    echo Installation completed in ../install directory.
)

cd ..
echo.
echo Build process finished.
pause
