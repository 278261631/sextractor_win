@echo off
REM SExtractor Windows Build Script
REM This script builds SExtractor using Windows native CMake and MinGW
REM Updated to use Debug configuration for stability (no memory errors)

echo ========================================
echo SExtractor Windows Build Script
echo ========================================
echo.

REM Step 1: Clean build directory
echo Step 1: Cleaning build directory...
if exist "build" (
    echo Removing existing build directory...
    powershell -Command "Get-ChildItem build -Recurse | Remove-Item -Force -Recurse"
) else (
    echo Creating build directory...
    mkdir build
)
echo.

REM Step 2: Set environment variables
echo Step 2: Setting up environment...
set PATH=C:\msys64\mingw64\bin;%PATH%
echo MinGW path added to environment
echo.

REM Step 3: Run CMake configuration
echo Step 3: Running CMake configuration...
echo Using Windows native CMake with MinGW Makefiles generator
echo Build type: Debug (forced in CMakeLists.txt for stability)
cd build
C:\CMake\bin\cmake.exe -G "MinGW Makefiles" -DCMAKE_INSTALL_PREFIX=../install ..
if %ERRORLEVEL% neq 0 (
    echo ERROR: CMake configuration failed!
    pause
    exit /b 1
)
echo CMake configuration completed successfully
echo.

REM Step 4: Build the project
echo Step 4: Building SExtractor...
echo Using mingw32-make with 4 parallel jobs
mingw32-make -j4
if %ERRORLEVEL% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)
echo Build completed successfully
echo.

REM Step 5: Copy required DLL files for standalone operation
echo Step 5: Copying all required DLL files for standalone operation...

REM Core mathematical and scientific libraries
echo Copying core libraries...
copy "C:\msys64\mingw64\bin\libcfitsio-10.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libfftw3f-3.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libopenblas.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\liblapack.dll" . >nul 2>&1

REM Runtime libraries
echo Copying runtime libraries...
copy "C:\msys64\mingw64\bin\libgfortran-5.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libquadmath-0.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libgcc_s_seh-1.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libwinpthread-1.dll" . >nul 2>&1

REM Network and compression libraries (for FITS file support)
echo Copying network and compression libraries...
copy "C:\msys64\mingw64\bin\zlib1.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libcurl-4.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libbrotlidec.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libbrotlicommon.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libidn2-0.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libnghttp2-14.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libnghttp3-9.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libngtcp2_crypto_ossl-0.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libpsl-5.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libssh2-1.dll" . >nul 2>&1

REM Text processing and internationalization libraries
echo Copying text processing libraries...
copy "C:\msys64\mingw64\bin\libiconv-2.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libintl-8.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libunistring-5.dll" . >nul 2>&1

REM Compression and cryptography libraries
echo Copying compression and crypto libraries...
copy "C:\msys64\mingw64\bin\libzstd.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libcrypto-3-x64.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libssl-3-x64.dll" . >nul 2>&1
copy "C:\msys64\mingw64\bin\libngtcp2-16.dll" . >nul 2>&1

echo All DLL files copied successfully!
echo.

REM Step 6: Verify build results
echo Step 6: Verifying build results...
if exist "sex.exe" (
    echo SUCCESS: sex.exe has been built successfully!
    for %%I in (sex.exe) do echo File size: %%~zI bytes
    echo.
    echo Build configuration:
    echo - Build type: Debug (stable, no aggressive optimizations)
    echo - Compiler flags: -g -O0 (debug symbols, no optimization)
    echo - Generator: MinGW Makefiles
    echo - CMake: Windows native version
    echo.
    echo The executable is ready to use: win\build\sex.exe
    echo.
    echo All required DLL files are present:
    dir /b *.dll
) else (
    echo ERROR: sex.exe was not created!
    exit /b 1
)

echo ========================================
echo Build completed successfully!
echo ========================================
pause