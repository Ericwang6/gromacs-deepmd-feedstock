#!/bin/bash
set -e

opt=""
# lapack and blas should be set explicitly otherwise GROMACS might pick a static version of libopenblas
opt="$opt -DGMX_BLAS_USER=$PREFIX/lib/libblas.so -DGMX_LAPACK_USER=$PREFIX/lib/liblapack.so"
LIBS="$LIBS $PREFIX/lib/libhwloc.so"

export CXXFLAGS=$( echo $CXXFLAGS | sed "s|-std=c++17| |g" )
export DEBUG_CXXFLAGS=$( echo $DEBUG_CXXFLAGS | sed "s|-std=c++17| |g" )
echo 'debug:CXXFLAGS'
echo $CXXFLAGS

# sed -i 's|-std=c++17| |g' ${BUILD_PREFIX}/etc/conda/activate.d/activate-gxx_linux-64.sh
# sed -i 's|-std=c++1z| |g' ${BUILD_PREFIX}/etc/conda/activate.d/activate-gxx_linux-64.sh
# ln -s ${BUILD_PREFIX}/lib/libcufft.so.10.0    ${BUILD_PREFIX}/lib/libcufft.so.10 
# ln -s ${PREFIX}/lib/libcufft.so.10.0    ${PREFIX}/lib/libcufft.so.10 

${BUILD_PREFIX}/bin/dp_gmx_patch -d . -v 2020.2 -p

# TODO: this is bad for CICD
source /public/wangyingze/env/cuda-10.1.env

mkdir build
cd build
cmake .. \
  $opt \
  -DGMX_SIMD=AVX2_256 \
  -DGMX_DEFAULT_SUFFIX=ON \
  -DGMX_MPI=ON \
  -DGMX_GPU=CUDA \
  -DGMX_FFT_LIBRARY=fftw3 \
  -DFFTWF_LIBRARY=${BUILD_PREFIX}/lib/libfftw3f.so \
  -DFFTWF_INCLUDE_DIR=${BUILD_PREFIX}/include \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  # -DCUDA_TOOLKIT_ROOT_DIR=${BUILD_PREFIX}
make -j
make install

ln -s ./gmx_mpi ${PREFIX}/bin/gmx
