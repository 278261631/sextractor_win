cmake_minimum_required(VERSION 3.15)
project(SExtractor VERSION 2.29.0 LANGUAGES C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Force Debug build type for stability (no aggressive optimizations)
# This ensures consistent behavior similar to CLion Debug builds
set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wno-array-parameter -Wno-unknown-pragmas")
# Debug flags: -g (debug symbols), -O0 (no optimization for stability)
set(CMAKE_C_FLAGS_DEBUG "-g -O0")
# Release flags: -O3 (aggressive optimization), -DNDEBUG (disable assertions)
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG")

# Define configuration
add_definitions(-DHAVE_CONFIG_H)

# Include directories
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/../src
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/fits
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/wcs
    ${CMAKE_CURRENT_SOURCE_DIR}/../src/levmar
)

# Find required libraries - assume all are available
find_library(MATH_LIBRARY m)

# Find FFTW library (prefer single precision)
find_library(FFTW_LIBRARY
    NAMES fftw3f libfftw3f fftw3 libfftw3
    PATHS C:/msys64/mingw64/lib /mingw64/lib
    REQUIRED
)
find_path(FFTW_INCLUDE_DIR
    NAMES fftw3.h
    PATHS C:/msys64/mingw64/include /mingw64/include
    REQUIRED
)
message(STATUS "Using FFTW: ${FFTW_LIBRARY}")
include_directories(${FFTW_INCLUDE_DIR})

# Find CFITSIO library
find_library(CFITSIO_LIBRARY
    NAMES cfitsio libcfitsio
    PATHS C:/msys64/mingw64/lib /mingw64/lib
    REQUIRED
)
find_path(CFITSIO_INCLUDE_DIR
    NAMES fitsio.h
    PATHS C:/msys64/mingw64/include /mingw64/include
    REQUIRED
)
message(STATUS "Using CFITSIO: ${CFITSIO_LIBRARY}")
include_directories(${CFITSIO_INCLUDE_DIR})

# Find LAPACK/BLAS libraries
find_library(LAPACK_LIBRARY
    NAMES lapack liblapack
    PATHS C:/msys64/mingw64/lib /mingw64/lib
)
find_library(BLAS_LIBRARY
    NAMES openblas libopenblas blas libblas
    PATHS C:/msys64/mingw64/lib /mingw64/lib
)

if(LAPACK_LIBRARY AND BLAS_LIBRARY)
    message(STATUS "Using LAPACK: ${LAPACK_LIBRARY}")
    message(STATUS "Using BLAS: ${BLAS_LIBRARY}")
endif()

# Create config.h
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

# FITS library sources (include all necessary files)
set(FITS_SOURCES
    ../src/fits/fitsbody.c
    ../src/fits/fitscat.c
    ../src/fits/fitscheck.c
    ../src/fits/fitscleanup.c
    ../src/fits/fitsconv.c
    ../src/fits/fitshead.c
    ../src/fits/fitskey.c
    ../src/fits/fitsmisc.c
    ../src/fits/fitsread.c
    ../src/fits/fitstab.c
    ../src/fits/fitsutil.c
    ../src/fits/fitswrite.c
)

# WCS library sources
set(WCS_SOURCES
    ../src/wcs/cel.c
    ../src/wcs/lin.c
    ../src/wcs/poly.c
    ../src/wcs/proj.c
    ../src/wcs/sph.c
    ../src/wcs/tnx.c
    ../src/wcs/wcs.c
    ../src/wcs/wcstrig.c
)

# LevMar library sources (exclude _core.c files as they are included by main files)
set(LEVMAR_SOURCES
    ../src/levmar/Axb.c
    ../src/levmar/lm.c
    ../src/levmar/lmbc.c
    ../src/levmar/lmblec.c
    ../src/levmar/lmbleic.c
    ../src/levmar/lmlec.c
    ../src/levmar/misc.c
)

# Main SExtractor sources (include all files)
set(SEX_SOURCES
    ../src/analyse.c
    ../src/assoc.c
    ../src/astrom.c
    ../src/back.c
    ../src/bpro.c
    ../src/catout.c
    ../src/check.c
    ../src/clean.c
    ../src/dgeo.c
    ../src/extract.c
    ../src/fft.c
    ../src/field.c
    ../src/filter.c
    ../src/fitswcs.c
    ../src/flag.c
    ../src/graph.c
    ../src/growth.c
    ../src/header.c
    ../src/image.c
    ../src/interpolate.c
    ../src/main.c
    ../src/makeit.c
    ../src/manobjlist.c
    ../src/misc.c
    ../src/neurro.c
    ../src/pattern.c
    ../src/pc.c
    ../src/photom.c
    ../src/plist.c
    ../src/prefs.c
    ../src/profit.c
    ../src/psf.c
    ../src/readimage.c
    ../src/refine.c
    ../src/retina.c
    ../src/scan.c
    ../src/som.c
    ../src/weight.c
    ../src/winpos.c
    ../src/xml.c
    windows_stubs.c
)

# Create static libraries
add_library(fits STATIC ${FITS_SOURCES})
add_library(wcs STATIC ${WCS_SOURCES})
add_library(levmar STATIC ${LEVMAR_SOURCES})

# Main executable
add_executable(sex ${SEX_SOURCES})

# Link all libraries (order matters for static linking)
target_link_libraries(sex
    fits
    wcs
    levmar
    ${FFTW_LIBRARY}
    ${CFITSIO_LIBRARY}
)

# Add optional LAPACK/BLAS if available
if(LAPACK_LIBRARY AND BLAS_LIBRARY)
    target_link_libraries(sex ${LAPACK_LIBRARY} ${BLAS_LIBRARY})
endif()

# Add system libraries last
target_link_libraries(sex -lm)

# Add linker flags to resolve symbol conflicts
set_target_properties(sex PROPERTIES
    LINK_FLAGS "-Wl,--allow-multiple-definition"
)

# Find and copy required DLL files
find_file(CFITSIO_DLL
    NAMES libcfitsio-10.dll cfitsio.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(FFTW_DLL
    NAMES libfftw3f-3.dll fftw3f.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(OPENBLAS_DLL
    NAMES libopenblas.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(LAPACK_DLL
    NAMES liblapack.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(GFORTRAN_DLL
    NAMES libgfortran-5.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(QUADMATH_DLL
    NAMES libquadmath-0.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(GCC_DLL
    NAMES libgcc_s_seh-1.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(ZLIB_DLL
    NAMES zlib1.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(CURL_DLL
    NAMES libcurl-4.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(WINPTHREAD_DLL
    NAMES libwinpthread-1.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

# Additional DLL dependencies
find_file(BROTLIDEC_DLL
    NAMES libbrotlidec.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(BROTLICOMMON_DLL
    NAMES libbrotlicommon.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(IDN2_DLL
    NAMES libidn2-0.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(NGHTTP2_DLL
    NAMES libnghttp2-14.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(NGHTTP3_DLL
    NAMES libnghttp3-9.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(NGTCP2_DLL
    NAMES libngtcp2-16.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(NGTCP2_CRYPTO_DLL
    NAMES libngtcp2_crypto_ossl-0.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(PSL_DLL
    NAMES libpsl-5.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(SSH2_DLL
    NAMES libssh2-1.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(ICONV_DLL
    NAMES libiconv-2.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(INTL_DLL
    NAMES libintl-8.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(UNISTRING_DLL
    NAMES libunistring-5.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(ZSTD_DLL
    NAMES libzstd.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(CRYPTO_DLL
    NAMES libcrypto-3-x64.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

find_file(SSL_DLL
    NAMES libssl-3-x64.dll
    PATHS /mingw64/bin
    NO_DEFAULT_PATH
)

# Copy DLL files to build directory after building
if(CFITSIO_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CFITSIO_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying CFITSIO DLL"
    )
endif()

if(FFTW_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${FFTW_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying FFTW DLL"
    )
endif()

if(OPENBLAS_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${OPENBLAS_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying OpenBLAS DLL"
    )
endif()

if(LAPACK_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${LAPACK_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying LAPACK DLL"
    )
endif()

if(GFORTRAN_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${GFORTRAN_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying GFortran DLL"
    )
endif()

if(QUADMATH_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${QUADMATH_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying QuadMath DLL"
    )
endif()

if(GCC_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${GCC_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying GCC DLL"
    )
endif()

if(ZLIB_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${ZLIB_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying ZLIB DLL"
    )
endif()

if(CURL_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CURL_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying CURL DLL"
    )
endif()

if(WINPTHREAD_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${WINPTHREAD_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying WinPthread DLL"
    )
endif()

if(BROTLIDEC_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${BROTLIDEC_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying BrotliDec DLL"
    )
endif()

if(IDN2_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${IDN2_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying IDN2 DLL"
    )
endif()

if(NGHTTP2_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${NGHTTP2_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying NGHTTP2 DLL"
    )
endif()

if(BROTLICOMMON_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${BROTLICOMMON_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying BrotliCommon DLL"
    )
endif()

if(NGHTTP3_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${NGHTTP3_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying NGHTTP3 DLL"
    )
endif()

if(NGTCP2_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${NGTCP2_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying NGTCP2 DLL"
    )
endif()

if(NGTCP2_CRYPTO_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${NGTCP2_CRYPTO_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying NGTCP2 Crypto DLL"
    )
endif()

if(PSL_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${PSL_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying PSL DLL"
    )
endif()

if(SSH2_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${SSH2_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying SSH2 DLL"
    )
endif()

if(ICONV_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${ICONV_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying ICONV DLL"
    )
endif()

if(INTL_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${INTL_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying INTL DLL"
    )
endif()

if(UNISTRING_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${UNISTRING_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying UNISTRING DLL"
    )
endif()

if(ZSTD_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${ZSTD_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying ZSTD DLL"
    )
endif()

if(CRYPTO_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CRYPTO_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying CRYPTO DLL"
    )
endif()

if(SSL_DLL)
    add_custom_command(TARGET sex POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${SSL_DLL} $<TARGET_FILE_DIR:sex>
        COMMENT "Copying SSL DLL"
    )
endif()

# Install targets
install(TARGETS sex DESTINATION bin)

# Install DLL files
if(CFITSIO_DLL)
    install(FILES ${CFITSIO_DLL} DESTINATION bin)
endif()

if(FFTW_DLL)
    install(FILES ${FFTW_DLL} DESTINATION bin)
endif()

if(OPENBLAS_DLL)
    install(FILES ${OPENBLAS_DLL} DESTINATION bin)
endif()

if(LAPACK_DLL)
    install(FILES ${LAPACK_DLL} DESTINATION bin)
endif()

if(GFORTRAN_DLL)
    install(FILES ${GFORTRAN_DLL} DESTINATION bin)
endif()

if(QUADMATH_DLL)
    install(FILES ${QUADMATH_DLL} DESTINATION bin)
endif()

if(GCC_DLL)
    install(FILES ${GCC_DLL} DESTINATION bin)
endif()

if(ZLIB_DLL)
    install(FILES ${ZLIB_DLL} DESTINATION bin)
endif()

if(CURL_DLL)
    install(FILES ${CURL_DLL} DESTINATION bin)
endif()

if(WINPTHREAD_DLL)
    install(FILES ${WINPTHREAD_DLL} DESTINATION bin)
endif()

if(BROTLIDEC_DLL)
    install(FILES ${BROTLIDEC_DLL} DESTINATION bin)
endif()

if(IDN2_DLL)
    install(FILES ${IDN2_DLL} DESTINATION bin)
endif()

if(NGHTTP2_DLL)
    install(FILES ${NGHTTP2_DLL} DESTINATION bin)
endif()

if(BROTLICOMMON_DLL)
    install(FILES ${BROTLICOMMON_DLL} DESTINATION bin)
endif()

if(NGHTTP3_DLL)
    install(FILES ${NGHTTP3_DLL} DESTINATION bin)
endif()

if(NGTCP2_DLL)
    install(FILES ${NGTCP2_DLL} DESTINATION bin)
endif()

if(NGTCP2_CRYPTO_DLL)
    install(FILES ${NGTCP2_CRYPTO_DLL} DESTINATION bin)
endif()

if(PSL_DLL)
    install(FILES ${PSL_DLL} DESTINATION bin)
endif()

if(SSH2_DLL)
    install(FILES ${SSH2_DLL} DESTINATION bin)
endif()

if(ICONV_DLL)
    install(FILES ${ICONV_DLL} DESTINATION bin)
endif()

if(INTL_DLL)
    install(FILES ${INTL_DLL} DESTINATION bin)
endif()

if(UNISTRING_DLL)
    install(FILES ${UNISTRING_DLL} DESTINATION bin)
endif()

if(ZSTD_DLL)
    install(FILES ${ZSTD_DLL} DESTINATION bin)
endif()

if(CRYPTO_DLL)
    install(FILES ${CRYPTO_DLL} DESTINATION bin)
endif()

if(SSL_DLL)
    install(FILES ${SSL_DLL} DESTINATION bin)
endif()
