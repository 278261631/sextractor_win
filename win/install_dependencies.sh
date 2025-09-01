#!/bin/bash
# SExtractor Windows 依赖安装脚本
# 在MSYS2 MinGW64终端中运行此脚本

echo "=== SExtractor Windows 依赖安装脚本 ==="
echo "正在安装编译SExtractor所需的所有依赖包..."
echo

# 检查是否在MSYS2环境中
if [[ ! "$MSYSTEM" == "MINGW64" ]]; then
    echo "错误: 请在MSYS2 MinGW64终端中运行此脚本"
    echo "启动: C:\\msys64\\mingw64.exe"
    exit 1
fi

# 更新包数据库
echo "1. 更新包数据库..."
pacman -Sy

# 安装基础开发工具
echo "2. 安装基础开发工具..."
pacman -S --noconfirm --needed \
    base-devel \
    mingw-w64-x86_64-toolchain \
    mingw-w64-x86_64-cmake \
    mingw-w64-x86_64-make

# 安装SExtractor依赖库
echo "3. 安装SExtractor依赖库..."
pacman -S --noconfirm --needed \
    mingw-w64-x86_64-fftw

# 可选依赖 (用户可以选择是否安装)
echo "4. 安装可选依赖库..."
read -p "是否安装CFITSIO库? (完整FITS支持) [y/N]: " install_cfitsio
if [[ $install_cfitsio =~ ^[Yy]$ ]]; then
    pacman -S --noconfirm --needed mingw-w64-x86_64-cfitsio
    echo "CFITSIO已安装"
else
    echo "跳过CFITSIO安装"
fi

read -p "是否安装数学库? (OpenBLAS, LAPACK) [y/N]: " install_math
if [[ $install_math =~ ^[Yy]$ ]]; then
    pacman -S --noconfirm --needed \
        mingw-w64-x86_64-openblas \
        mingw-w64-x86_64-lapack
    echo "数学库已安装"
else
    echo "跳过数学库安装"
fi

# 验证安装
echo
echo "5. 验证安装..."
echo "检查编译器:"
gcc --version | head -1
echo

echo "检查CMake:"
cmake --version | head -1
echo

echo "检查FFTW:"
if pkg-config --exists fftw3; then
    echo "✅ FFTW已正确安装"
    echo "   版本: $(pkg-config --modversion fftw3)"
    echo "   库文件: $(find /mingw64/lib -name "libfftw3*" | head -3)"
else
    echo "❌ FFTW未正确安装"
fi

echo "检查CFITSIO:"
if pkg-config --exists cfitsio 2>/dev/null; then
    echo "✅ CFITSIO已安装"
    echo "   版本: $(pkg-config --modversion cfitsio)"
elif ls /mingw64/lib/libcfitsio* >/dev/null 2>&1; then
    echo "✅ CFITSIO已安装 (无pkg-config)"
else
    echo "ℹ️  CFITSIO未安装 (可选)"
fi

echo
echo "=== 安装完成 ==="
echo "现在可以编译SExtractor了:"
echo "  cd /e/github/sextractor_win/win"
echo "  ./build.bat"
echo "或者:"
echo "  mkdir build && cd build"
echo "  cmake -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release .."
echo "  make -j4"
