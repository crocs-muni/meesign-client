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

set(CARGO_CMD cargo build --target ${RUST_TARGET} ${CARGO_BUILD_TYPE_OPT})

if(WIN32)
  set(
    CARGO_CMD
    ${CMAKE_COMMAND} -E env
    OPENSSL_STATIC=1
    ${CARGO_CMD}
  )
elseif(ANDROID)
  find_package(openssl REQUIRED)
  add_library(OpenSSL::Crypto ALIAS openssl::crypto)
  add_library(OpenSSL::SSL ALIAS openssl::ssl)

  get_target_property(CRYPTO_LIB_LOCATION OpenSSL::Crypto IMPORTED_LOCATION)
  get_filename_component(CRYPTO_LIB_DIR ${CRYPTO_LIB_LOCATION} DIRECTORY)
  get_target_property(SSL_LIB_LOCATION OpenSSL::SSL IMPORTED_LOCATION)
  get_filename_component(SSL_LIB_DIR ${SSL_LIB_LOCATION} DIRECTORY)
  get_target_property(CRYPTO_INCLUDE_DIR OpenSSL::Crypto INTERFACE_INCLUDE_DIRECTORIES)

  list(APPEND MPC_SIGS_DEPS ${CRYPTO_LIB_LOCATION})
  list(APPEND MPC_SIGS_DEPS ${SSL_LIB_LOCATION})
  set(MPC_SIGS_DEPS ${MPC_SIGS_DEPS} PARENT_SCOPE)

  # invoke cargo so that openssl-sys
  # correctly finds our Android OpenSSL distribution

  # FIXME:
  # openssl crate requires both ssl and crypto library,
  # additionally we can specify only one linker search path for them,
  # but prefab puts each module in a separate directory;
  # to workaround that list only crpyto in OPENSSL_LIBS
  # (so that openssl-sys checks pass) and add ssl through RUSTFLAGS
  set(RUSTFLAGS "-ldylib=ssl" "-L${SSL_LIB_DIR}")
  set(
    CARGO_CMD
    ${CMAKE_COMMAND} -E env
    OPENSSL_LIBS=crypto
    RUSTFLAGS="${RUSTFLAGS}"
    OPENSSL_LIB_DIR=${CRYPTO_LIB_DIR} OPENSSL_INCLUDE_DIR=${CRYPTO_INCLUDE_DIR}
    # CC and AR are necessary for Rust cc crate (used e.g. by secp256k1-sys),
    # see https://crates.io/crates/cc
    CC=${CMAKE_C_COMPILER}
    AR=${CMAKE_AR}
    ${CARGO_CMD}
  )
endif()

add_custom_target(
  cargo_mpc_sigs
  COMMAND ${CARGO_CMD}
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
