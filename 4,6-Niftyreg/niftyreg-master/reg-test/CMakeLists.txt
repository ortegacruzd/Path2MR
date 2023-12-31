find_package(Catch2 3)
if(NOT Catch2_FOUND)
  set(BUILD_TESTING OFF CACHE BOOL "To build the unit tests" FORCE)
  message(STATUS "Catch2 not found")
  message(SEND_ERROR "Catch2 is required to generate the unit test.
  The BUILD_TESTING flag is turned OFF")
  return()
endif(NOT Catch2_FOUND)
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Build the coverage test
if(NOT MSVC)
  option(WITH_COVERAGE "Set up the C, CXX and linker flags to run the coverage test" OFF)
  if(WITH_COVERAGE)
    set(CTEST_START_WITH_EMPTY_BINARY_DIRECTORY_ONCE TRUE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING
      "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
    set(CMAKE_CXX_FLAGS_DEBUG
      "-g -O0 -Wall -W -Wunused-variable -Wunused-parameter -Wunused-function -Wunused -Wno-system-headers -Wno-deprecated -Woverloaded-virtual -Wwrite-strings -fprofile-arcs -ftest-coverage"
      CACHE STRING "Force the debug CXX flags for the coverage test" FORCE)
    set(CMAKE_EXE_LINKER_FLAGS_DEBUG
      "-fprofile-arcs -ftest-coverage"
      CACHE STRING "Force the debug linker flags for the coverage test" FORCE)
    set(BUILD_ALL_DEP ON CACHE BOOL "All the dependencies are build" FORCE)
    configure_file(${CMAKE_SOURCE_DIR}/reg-test/CTestCustom.cmake.in
                   ${CMAKE_BINARY_DIR}/CTestCustom.cmake)
  endif(WITH_COVERAGE)
endif(NOT MSVC)
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Set the build name
set(CTEST_BUILD_NAME "${CMAKE_SYSTEM}_${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}_cmake-${CMAKE_VERSION}_${CMAKE_BUILD_TYPE}")
if(USE_SSE)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_sse")
endif(USE_SSE)
if(USE_OPENMP)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_openmp")
endif(USE_OPENMP)
if(USE_CUDA)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_cuda-${CUDA_VERSION}")
endif(USE_CUDA)
if(USE_OPENCL)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}_opencl")
endif(USE_OPENCL)
if(NOT MSVC)
  unset(BUILDNAME CACHE)
  unset(BUILDNAME)
  set(BUILDNAME ${CTEST_BUILD_NAME} CACHE STRING "Build name variable for CDash" FORCE)
else(MSVC)
  set(BUILDNAME ${CTEST_BUILD_NAME} CACHE STRING "Build name variable for CDash")
  message(STATUS "The buildname might need manual editing")
endif(NOT MSVC)
mark_as_advanced(BUILDNAME)
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
include(CTest)
include(Catch)
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
set(EXEC_LIST reg_test_affine_deformation_field)
set(EXEC_LIST reg_test_interpolation ${EXEC_LIST})


foreach(EXEC ${EXEC_LIST})
  add_executable(${EXEC} ${EXEC}.cpp)
  target_link_libraries(${EXEC} PRIVATE Catch2::Catch2WithMain)
  target_link_libraries(${EXEC} PRIVATE _reg_aladin)
  target_link_libraries(${EXEC} PRIVATE _reg_f3d)
  catch_discover_tests(${EXEC})
endforeach(EXEC)
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------