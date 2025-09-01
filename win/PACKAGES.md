# SExtractor Windows 编译所需包列表

## 必需包 (Required Packages)

### 基础开发工具
```bash
base-devel                          # 基础开发工具集
mingw-w64-x86_64-toolchain         # GCC编译器工具链
mingw-w64-x86_64-cmake             # CMake构建系统
mingw-w64-x86_64-make              # Make构建工具
```

### 核心依赖库
```bash
mingw-w64-x86_64-fftw              # FFTW - 快速傅里叶变换库 (必需)
```

## 可选包 (Optional Packages)

### FITS文件支持
```bash
mingw-w64-x86_64-cfitsio           # CFITSIO - FITS文件I/O库
```

### 数学计算库
```bash
mingw-w64-x86_64-openblas          # OpenBLAS - 优化的线性代数库
mingw-w64-x86_64-lapack            # LAPACK - 线性代数包
mingw-w64-x86_64-gsl               # GSL - GNU科学计算库
```

### 调试和开发工具
```bash
mingw-w64-x86_64-gdb               # GDB调试器
mingw-w64-x86_64-pkg-config       # pkg-config工具
```

### 代理 (如果需要 以及修改为自己的端口)
```bash
export http_proxy=http://127.0.0.1:10551
export https_proxy=http://127.0.0.1:10551
```

## 安装命令

### 最小安装 (仅核心功能)
```bash
pacman -S --noconfirm base-devel mingw-w64-x86_64-toolchain mingw-w64-x86_64-cmake mingw-w64-x86_64-make mingw-w64-x86_64-fftw
```

### 完整安装 (包含所有可选功能)
```bash
pacman -S --noconfirm \
    base-devel \
    mingw-w64-x86_64-toolchain \
    mingw-w64-x86_64-cmake \
    mingw-w64-x86_64-make \
    mingw-w64-x86_64-fftw \
    mingw-w64-x86_64-cfitsio \
    mingw-w64-x86_64-openblas \
    mingw-w64-x86_64-lapack \
    mingw-w64-x86_64-gsl \
    mingw-w64-x86_64-gdb \
    mingw-w64-x86_64-pkg-config
```

## 包说明

| 包名 | 用途 | 必需性 | 说明 |
|------|------|--------|------|
| base-devel | 基础开发 | 必需 | 包含make, autotools等基础工具 |
| toolchain | 编译器 | 必需 | GCC, G++, binutils等编译工具 |
| cmake | 构建系统 | 必需 | 项目使用CMake构建 |
| make | 构建工具 | 必需 | 执行编译过程 |
| fftw | FFT计算 | 必需 | SExtractor核心算法依赖 |
| cfitsio | FITS支持 | 可选 | 完整的FITS文件格式支持 |
| openblas | 线性代数 | 可选 | 优化的数学运算性能 |
| lapack | 线性代数 | 可选 | 高级线性代数算法 |
| gsl | 科学计算 | 可选 | 额外的数学函数库 |
| gdb | 调试 | 可选 | 程序调试工具 |
| pkg-config | 配置 | 可选 | 库配置信息工具 |

## 验证安装

### 检查编译器
```bash
gcc --version
g++ --version
```

### 检查构建工具
```bash
cmake --version
make --version
```

### 检查库
```bash
# FFTW
pkg-config --exists fftw3 && echo "FFTW OK" || echo "FFTW Missing"
ls /mingw64/lib/libfftw3*

# CFITSIO (如果安装)
pkg-config --exists cfitsio && echo "CFITSIO OK" || echo "CFITSIO Missing"
ls /mingw64/lib/libcfitsio*

# 头文件
ls /mingw64/include/fftw3.h
ls /mingw64/include/fitsio.h  # 如果安装了CFITSIO
```

## 磁盘空间要求

- **最小安装**: ~500MB
- **完整安装**: ~1GB
- **编译过程**: 额外需要~200MB临时空间

## 网络要求

- 下载大小: 100-300MB (取决于已安装的包)
- 建议使用稳定的网络连接
- 如果下载缓慢，可以更换MSYS2镜像源
