add_library(pdf-sig SHARED pdf-sig.cpp SigGenerator.cpp)
target_link_libraries(pdf-sig OpenSSL::Crypto PoDoFo)
target_include_directories(pdf-sig PRIVATE "${PODOFO_INCLUDE_DIR}")
