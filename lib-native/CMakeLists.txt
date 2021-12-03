if(NOT RUST_TARGET)
  message(FATAL_ERROR "Rust target not set")
endif()

if(CMAKE_BUILD_TYPE)
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(RUST_BUILD_TYPE "debug")
  else()
    set(RUST_BUILD_TYPE "release")
    set(CARGO_BUILD_TYPE_OPT "--release")
  endif()
else()
  # CMAKE_BUILD_TYPE not set in multi-config generators
  # but using gnenerator expressions in OUTPUT part of add_custom_command()
  # requires cmake 3.20+, so try to avoid it for now
  set(RUST_BUILD_TYPE "$<IF:$<CONFIG:Debug>,debug,release>")
  set(CARGO_BUILD_TYPE_OPT "$<$<NOT:$<CONFIG:Debug>>:--release>")
endif()

set(MPC_SIGS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mpc-sigs")
set(MPC_SIGS_BUILD_DIR "${MPC_SIGS_DIR}/target/${RUST_TARGET}/${RUST_BUILD_TYPE}")
set(MPC_SIGS_LIB "${MPC_SIGS_BUILD_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}mpc_sigs${CMAKE_SHARED_LIBRARY_SUFFIX}")
if(WIN32)
  set(MPC_SIGS_IMPLIB "${MPC_SIGS_LIB}.lib")
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/")

find_package(OpenSSL REQUIRED)
find_package(PoDoFo REQUIRED)

if(ANDROID)
  add_library(OpenSSL::Crypto ALIAS openssl::crypto)
  add_library(PoDoFo ALIAS podofo::podofo)
endif()

add_custom_target(
  cargo_mpc_sigs
  COMMAND cargo build --target ${RUST_TARGET} ${CARGO_BUILD_TYPE_OPT}
  WORKING_DIRECTORY ${MPC_SIGS_DIR}
  BYPRODUCTS ${MPC_SIGS_LIB} ${MPC_SIGS_IMPLIB}
)

add_library(mpc_sigs INTERFACE)
add_dependencies(mpc_sigs cargo_mpc_sigs)
if(WIN32)
  target_link_libraries(mpc_sigs INTERFACE "${MPC_SIGS_IMPLIB}")
else()
  target_link_libraries(mpc_sigs INTERFACE "${MPC_SIGS_LIB}")
endif()

set(MPC_SIGS_LIB "${MPC_SIGS_LIB}" PARENT_SCOPE)

add_subdirectory(pdf-sig)
