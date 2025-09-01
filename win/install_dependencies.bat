@echo off
REM SExtractor Windows 依赖安装脚本
REM 此脚本会启动MSYS2并安装所需依赖

echo === SExtractor Windows 依赖安装脚本 ===
echo 正在准备安装编译SExtractor所需的所有依赖包...
echo.

REM 检查MSYS2是否存在
if not exist "C:\msys64\usr\bin\bash.exe" (
    echo 错误: 未找到MSYS2安装
    echo 请先安装MSYS2: https://www.msys2.org/
    echo 安装路径应为: C:\msys64\
    pause
    exit /b 1
)

echo 找到MSYS2安装，正在启动安装过程...
echo.

REM 创建临时安装脚本
echo #!/bin/bash > %TEMP%\install_sextractor_deps.sh
echo # 自动生成的依赖安装脚本 >> %TEMP%\install_sextractor_deps.sh
echo. >> %TEMP%\install_sextractor_deps.sh
echo echo "=== 开始安装SExtractor依赖 ===" >> %TEMP%\install_sextractor_deps.sh
echo. >> %TEMP%\install_sextractor_deps.sh
echo # 更新包数据库 >> %TEMP%\install_sextractor_deps.sh
echo echo "1. 更新包数据库..." >> %TEMP%\install_sextractor_deps.sh
echo pacman -Sy >> %TEMP%\install_sextractor_deps.sh
echo. >> %TEMP%\install_sextractor_deps.sh
echo # 安装基础工具 >> %TEMP%\install_sextractor_deps.sh
echo echo "2. 安装基础开发工具..." >> %TEMP%\install_sextractor_deps.sh
echo pacman -S --noconfirm --needed base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake mingw-w64-x86_64-make >> %TEMP%\install_sextractor_deps.sh
echo. >> %TEMP%\install_sextractor_deps.sh
echo # 安装FFTW >> %TEMP%\install_sextractor_deps.sh
echo echo "3. 安装FFTW库..." >> %TEMP%\install_sextractor_deps.sh
echo pacman -S --noconfirm --needed mingw-w64-x86_64-fftw >> %TEMP%\install_sextractor_deps.sh
echo. >> %TEMP%\install_sextractor_deps.sh
echo # 验证安装 >> %TEMP%\install_sextractor_deps.sh
echo echo "4. 验证安装..." >> %TEMP%\install_sextractor_deps.sh
echo gcc --version ^| head -1 >> %TEMP%\install_sextractor_deps.sh
echo cmake --version ^| head -1 >> %TEMP%\install_sextractor_deps.sh
echo if pkg-config --exists fftw3; then >> %TEMP%\install_sextractor_deps.sh
echo     echo "✅ FFTW已正确安装" >> %TEMP%\install_sextractor_deps.sh
echo else >> %TEMP%\install_sextractor_deps.sh
echo     echo "❌ FFTW安装失败" >> %TEMP%\install_sextractor_deps.sh
echo fi >> %TEMP%\install_sextractor_deps.sh
echo. >> %TEMP%\install_sextractor_deps.sh
echo echo "=== 安装完成 ===" >> %TEMP%\install_sextractor_deps.sh
echo echo "现在可以编译SExtractor了" >> %TEMP%\install_sextractor_deps.sh
echo read -p "按Enter键关闭..." >> %TEMP%\install_sextractor_deps.sh

REM 启动MSYS2并执行安装脚本
echo 正在启动MSYS2 MinGW64终端...
C:\msys64\usr\bin\bash.exe -l -c "cd /tmp && bash install_sextractor_deps.sh"

REM 清理临时文件
del %TEMP%\install_sextractor_deps.sh

echo.
echo 依赖安装完成！
echo 现在可以运行 build.bat 来编译SExtractor
pause
