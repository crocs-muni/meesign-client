cmake_minimum_required(VERSION 3.15)

project(meesign_client)

set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

if(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
  set(RUST_TARGET "aarch64-linux-android")
elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a")
  set(RUST_TARGET "armv7-linux-androideabi")
elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
  set(RUST_TARGET "x86_64-linux-android")
elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86")
  set(RUST_TARGET "i686-linux-android")
endif()

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../../../../meesign_native/native" native)

add_library(meesign_crypto_lib SHARED IMPORTED)
set_property(TARGET meesign_crypto_lib PROPERTY IMPORTED_LOCATION ${MEESIGN_CRYPTO_LIB})
add_dependencies(meesign_crypto_lib meesign_crypto)

# FIXME: how to get rid of this dummy?
add_library(dummy SHARED dummy.cpp)
target_link_libraries(dummy meesign_crypto_lib)
