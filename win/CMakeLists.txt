cmake_minimum_required(VERSION 3.15)
project(SExtractor VERSION 2.29.0 LANGUAGES C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wno-array-parameter -Wno-unknown-pragmas")
set(CMAKE_C_FLAGS_DEBUG "-g -O0")
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
    PATHS /mingw64/lib
    REQUIRED
)
find_path(FFTW_INCLUDE_DIR
    NAMES fftw3.h
    PATHS /mingw64/include
    REQUIRED
)
message(STATUS "Using FFTW: ${FFTW_LIBRARY}")
include_directories(${FFTW_INCLUDE_DIR})

# Find CFITSIO library
find_library(CFITSIO_LIBRARY
    NAMES cfitsio libcfitsio
    PATHS /mingw64/lib
    REQUIRED
)
find_path(CFITSIO_INCLUDE_DIR
    NAMES fitsio.h
    PATHS /mingw64/include
    REQUIRED
)
message(STATUS "Using CFITSIO: ${CFITSIO_LIBRARY}")
include_directories(${CFITSIO_INCLUDE_DIR})

# Find LAPACK/BLAS libraries
find_library(LAPACK_LIBRARY
    NAMES lapack liblapack
    PATHS /mingw64/lib
)
find_library(BLAS_LIBRARY
    NAMES openblas libopenblas blas libblas
    PATHS /mingw64/lib
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

# Install targets
install(TARGETS sex DESTINATION bin)
