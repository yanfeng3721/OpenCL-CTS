# for 32-bit Windows cross compilation
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_C_COMPILER icx-cl)
set(CMAKE_CXX_COMPILER icx-cl)
set(CMAKE_SYSTEM_PROCESSOR x86)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /Qm32")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Qm32")
