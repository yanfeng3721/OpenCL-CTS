# OpenCL-CTS
The OpenCL Conformance Tests

## 1 .Build on Linux
###    Release build
    ./build.sh linux release 24
###    Debug build
    ./build.sh linux debug 24

## 2 .Build on Win64
###    Using ICC compiler for 2022.1 release
    ics ws -archive deploy_mainline efi2win 20211109_000000
    ics set config -ws efi2win prod vs=2019 && wcontext
###    Release build
    ./build.sh win release 24
###    Debug build
    ./build.sh win debug 24

## 3 .Build on Win32
###    Using ICC compiler for 2022.1 release
    ics ws -archive deploy_mainline efi2win 20211109_000000
    ics set config -ws x86winefi2 prod vs=2019 && wcontext
###    Release build
    ./build.sh win release 24
###    Debug build
    ./build.sh win debug 24
