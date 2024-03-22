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

set(MEESIGN_CRYPTO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/meesign-crypto")
set(MEESIGN_CRYPTO_BUILD_DIR "${MEESIGN_CRYPTO_DIR}/target/${RUST_TARGET}/${RUST_BUILD_TYPE}")
set(MEESIGN_CRYPTO_LIB "${MEESIGN_CRYPTO_BUILD_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}meesign_crypto${CMAKE_SHARED_LIBRARY_SUFFIX}")
if(WIN32)
  set(MEESIGN_CRYPTO_IMPLIB "${MEESIGN_CRYPTO_LIB}.lib")
endif()

set(CARGO_CMD cargo build --target ${RUST_TARGET} ${CARGO_BUILD_TYPE_OPT})

if(ANDROID)
  set(
    CARGO_CMD
    ${CMAKE_COMMAND} -E env
    # CC and AR are necessary for Rust cc crate (used e.g. by secp256k1-sys),
    # see https://crates.io/crates/cc
    CC=${CMAKE_C_COMPILER}
    AR=${CMAKE_AR}
    ${CARGO_CMD}
  )
endif()

add_custom_target(
  cargo_meesign_crypto
  COMMAND ${CARGO_CMD}
  WORKING_DIRECTORY ${MEESIGN_CRYPTO_DIR}
  BYPRODUCTS ${MEESIGN_CRYPTO_LIB} ${MEESIGN_CRYPTO_IMPLIB}
)

add_library(meesign_crypto INTERFACE)
add_dependencies(meesign_crypto cargo_meesign_crypto)
if(WIN32)
  target_link_libraries(meesign_crypto INTERFACE "${MEESIGN_CRYPTO_IMPLIB}")
else()
  target_link_libraries(meesign_crypto INTERFACE "${MEESIGN_CRYPTO_LIB}")
endif()

set(MEESIGN_CRYPTO_LIB "${MEESIGN_CRYPTO_LIB}" PARENT_SCOPE)
