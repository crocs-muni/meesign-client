# - Find PoDoFo
# Find the native PoDoFo includes and library
#
#  PODOFO_INCLUDE_DIR - where to find winscard.h, wintypes.h, etc.
#  PODOFO_LIBRARIES   - List of libraries when using PoDoFo.
#  PODOFO_FOUND       - True if PoDoFo found.


IF (PODOFO_INCLUDE_DIR)
  # Already in cache, be silent
  SET(PODOFO_FIND_QUIETLY TRUE)
ENDIF (PODOFO_INCLUDE_DIR)

FIND_PATH(PODOFO_INCLUDE_DIR podofo/podofo.h)
FIND_LIBRARY(PODOFO_LIBRARY NAMES podofo)

# handle the QUIETLY and REQUIRED arguments and set PODOFO_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(PoDoFo DEFAULT_MSG PODOFO_LIBRARY PODOFO_INCLUDE_DIR)

IF(PODOFO_FOUND)
  SET( PODOFO_LIBRARIES ${PODOFO_LIBRARY} )
ELSE(PODOFO_FOUND)
  SET( PODOFO_LIBRARIES )
ENDIF(PODOFO_FOUND)

MARK_AS_ADVANCED(PODOFO_LIBRARY PODOFO_INCLUDE_DIR)

add_library(PoDoFo UNKNOWN IMPORTED)
set_target_properties(PoDoFo PROPERTIES
  IMPORTED_LOCATION "${PODOFO_LIBRARY}")
