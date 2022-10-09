#!/usr/bin/env bash

set -e

os=$1
build_type=$2
jobs=$3
cmake_extra_params="-DGL_IS_SUPPORTED=OFF"
c_compiler="gcc"
cxx_compiler="g++"

if [ ${build_type} != "debug" ]; then
    build_type="release"
    build_opt="/MD"
else
    build_type="debug"
    build_opt="/MDd"
fi

if [ ${os} = win ]; then
    c_compiler="icl"
    cxx_compiler="icl"
    cmake_extra_params="-DGL_IS_SUPPORTED=OFF -DCMAKE_C_FLAGS_RELEASE=${build_opt} -DCMAKE_CXX_FLAGS_RELEASE=${build_opt}"
fi

echo "Build OpenCL-CTS on ${os} ${build_type} mode with compiler ${c_compiler}"

echo "Clone repositories"
git clone https://github.com/KhronosGroup/OpenCL-Headers.git --depth 1
git clone https://github.com/KhronosGroup/OpenCL-ICD-Loader.git --depth 1

echo "Build ICD loader"
pushd OpenCL-ICD-Loader
cmake cmake -G "Unix Makefiles" -DOPENCL_ICD_LOADER_HEADERS_DIR=../OpenCL-Headers -DCMAKE_BUILD_TYPE=${build_type} .
make -j ${jobs}
popd

echo "Apply patch"
git clone https://github.com/intel-innersource/drivers.gpu.validation.opencl-cts-patches.git
git apply drivers.gpu.validation.opencl-cts-patches/0002-Turn-off-stdout-buffering-no-compatibility.patch

echo "Build tests"
mkdir -p Build
pushd Build
cmake -G "Unix Makefiles" -DCL_INCLUDE_DIR=OpenCL-Headers -DCL_LIB_DIR=OpenCL-ICD-Loader -DCMAKE_C_COMPILER=${c_compiler} -DCMAKE_CXX_COMPILER=${cxx_compiler} -DCMAKE_BUILD_TYPE=${build_type} -DOPENCL_LIBRARIES=OpenCL ${cmake_extra_params} ..
make -j ${jobs}
popd

echo "Build done"
rm -rf OpenCL-*
rm -rf drivers*
