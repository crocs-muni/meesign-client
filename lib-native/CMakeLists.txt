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

if(NOT ANDROID)
  find_package(OpenSSL REQUIRED)
  find_package(PoDoFo REQUIRED)
else()
  find_package(openssl REQUIRED)
  find_package(podofo REQUIRED)
  add_library(OpenSSL::Crypto ALIAS openssl::crypto)
  add_library(OpenSSL::SSL ALIAS openssl::ssl)
  add_library(PoDoFo ALIAS podofo::podofo)

  get_target_property(CRYPTO_LIB_LOCATION OpenSSL::Crypto IMPORTED_LOCATION)
  get_filename_component(CRYPTO_LIB_DIR ${CRYPTO_LIB_LOCATION} DIRECTORY)
  get_target_property(SSL_LIB_LOCATION OpenSSL::SSL IMPORTED_LOCATION)
  get_filename_component(SSL_LIB_DIR ${SSL_LIB_LOCATION} DIRECTORY)
  get_target_property(CRYPTO_INCLUDE_DIR OpenSSL::Crypto INTERFACE_INCLUDE_DIRECTORIES)

  # invoke cargo so that openssl-sys
  # correctly finds our Android OpenSSL distribution

  # FIXME:
  # openssl crate requires both ssl and crypto library,
  # additionally we can specify only linker search path for them,
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
    CC=${CMAKE_C_COMPILER}
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

add_subdirectory(pdf-sig)

if(ANDROID)
  # FIXME: pdf-sig does not need it, but mpc-sigs does,
  # this way android build includes it in the created apk
  target_link_libraries(pdf-sig OpenSSL::SSL)
endif(ANDROID)
if(WIN32)
  # FIXME: ditto
  target_link_libraries(pdf-sig OpenSSL::SSL)
  target_link_options(pdf-sig PRIVATE "/INCLUDE:OPENSSL_init_ssl")
endif(WIN32)
