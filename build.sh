#!/usr/bin/env bash

set -e

export CMAKE_VERSION=v_3_25_3

os=$1
build_type=$2
jobs=$3
cmake_extra_params="-DGL_IS_SUPPORTED=OFF"
c_compiler="gcc"
cxx_compiler="g++"

if [ ${build_type} != "debug" ]; then
    build_type="Release"
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
git clone https://github.com/KhronosGroup/OpenCL-Headers.git
pushd OpenCL-Headers
git reset --hard 9ce9a722ba06ea87487cd08bd2001276e2aef8cd
popd
git clone https://github.com/KhronosGroup/OpenCL-ICD-Loader.git
pushd OpenCL-ICD-Loader
git reset --hard 229410f86a8c8c9e0f86f195409e5481a2bae067
popd 
#git clone https://github.com/KhronosGroup/Vulkan-Headers.git --depth 1
#git clone https://github.com/KhronosGroup/Vulkan-Loader.git --depth 1

echo "Build ICD loader"
pushd OpenCL-ICD-Loader
cmake cmake -G "Unix Makefiles" -DOPENCL_ICD_LOADER_HEADERS_DIR=../OpenCL-Headers -DCMAKE_BUILD_TYPE=${build_type} .
make -j ${jobs}
popd

#echo "Build Vulkan-Loader"
#mkdir -p Vulkan-Loader/build
#pushd Vulkan-Loader/build
#python3 ../scripts/update_deps.py
#cmake .. -G Ninja \
#      -DCMAKE_BUILD_TYPE=Release \
#      -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE} \
#      -DBUILD_WSI_XLIB_SUPPORT=OFF \
#      -DBUILD_WSI_XCB_SUPPORT=OFF \
#      -DBUILD_WSI_WAYLAND_SUPPORT=OFF \
#      -DUSE_GAS=OFF \
#      -C helper.cmake ..
#cmake --build . -j2
#popd

echo "Apply patch"
git clone https://github.com/intel-innersource/drivers.gpu.validation.opencl-cts-patches.git
pushd drivers.gpu.validation.opencl-cts-patches
git checkout 11de4e78d5ac514a21970b2cc738d952197b5f12
popd
git apply drivers.gpu.validation.opencl-cts-patches/0001-Turn-off-stdout-buffering-no-compatibility.patch

echo "Build tests"
mkdir -p Build
pushd Build
cmake -G "Unix Makefiles" -DCL_INCLUDE_DIR=OpenCL-Headers -DCL_LIB_DIR=OpenCL-ICD-Loader -DCMAKE_C_COMPILER=${c_compiler} -DCMAKE_CXX_COMPILER=${cxx_compiler} -DCMAKE_BUILD_TYPE=${build_type} -DOPENCL_LIBRARIES=OpenCL -DVULKAN_INCLUDE_DIR=Vulkan-Headers/include/ -DVULKAN_LIB_DIR=Vulkan-Loader/build/loader/ ${cmake_extra_params} ..
make -j ${jobs}
popd

echo "Build done"
rm -rf OpenCL-*
rm -rf drivers*
#rm -rf Vulkan-*
