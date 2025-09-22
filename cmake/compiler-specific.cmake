# This file is included from the def.cmake CMakeLists.txt file.
# It sets up the compiler specific flags.

# Define the common flags and options for GCC
option(PROFILE "Enable profiling" OFF)
add_library(common_compiler_flags INTERFACE)

# Define the flags for the C compiler
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64")

  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_definitions(common_compiler_flags INTERFACE CC_GCC_LIKE_ASM)

    target_compile_options(
      common_compiler_flags INTERFACE -Wall -funroll-loops -Wcast-align
                                      -Werror=implicit-function-declaration -Werror=implicit-int
    )

    # If GCC version is greater than 4.2.0, enable the following flags
    if(CMAKE_C_COMPILER_VERSION VERSION_GREATER 4.2.0)
      target_compile_options(
        common_compiler_flags INTERFACE -m64 -minline-all-stringops -falign-loops -ftree-vectorize
                                        -fno-strict-overflow -mtune=generic
      )
      target_link_options(common_compiler_flags INTERFACE -m64)
    endif()
  elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang")
    target_compile_definitions(common_compiler_flags INTERFACE CC_GCC_LIKE_ASM)
    target_compile_options(common_compiler_flags INTERFACE -m64)
    target_link_options(common_compiler_flags INTERFACE -m64)
  endif()

elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i386|i486|i586|i686")

  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_definitions(common_compiler_flags INTERFACE CC_GCC_LIKE_ASM)

    target_compile_options(
      common_compiler_flags INTERFACE -Wall -funroll-loops -Wcast-align
                                      -Werror=implicit-function-declaration -Werror=implicit-int
    )

    # If GCC version is greater than 4.2.0, enable the following flags
    if(CMAKE_C_COMPILER_VERSION VERSION_GREATER 4.2.0)
      target_compile_options(
        common_compiler_flags INTERFACE -m32 -minline-all-stringops -falign-loops -ftree-vectorize
                                        -fno-strict-overflow -mtune=generic
      )
    endif()
  elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang")
    target_compile_definitions(common_compiler_flags INTERFACE CC_GCC_LIKE_ASM)
    target_compile_options(common_compiler_flags INTERFACE -m32)
    target_link_options(common_compiler_flags INTERFACE -m32)
  endif()

elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")

  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_definitions(common_compiler_flags INTERFACE CC_GCC_LIKE_ASM)

    # target_compile_options(common INTERFACE -O0 # <$<$<BOOL:${PROFILE}>:-pg> )

    # target_compile_options( common INTERFACE -marm -march=armv5t
    # -funroll-loops -fsigned-char )

    # # If GCC version is greater than 4.2.0, enable the following flags
    # if(CMAKE_C_COMPILER_VERSION VERSION_GREATER 4.2.0) target_compile_options(
    # common INTERFACE -ftree-vectorize -fno-strict-overflow ) endif()

  endif()

elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "ppc64$")
  # PowerPC 64-bit specific flags
  if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
    target_compile_definitions(common_compiler_flags INTERFACE CC_GCC_LIKE_ASM)
    target_compile_options(common_compiler_flags INTERFACE -funroll-loops -fsigned-char)

    # Try to get CPUTYPE from the environment, fallback to "powerpc64" if not set
    if(DEFINED ENV{CPUTYPE} AND NOT "$ENV{CPUTYPE}" STREQUAL "")
      set(CPUTYPE "$ENV{CPUTYPE}")
    else()
      set(CPUTYPE "powerpc64")
    endif()

    if(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 4.2)
      target_compile_options(
        common_compiler_flags INTERFACE -ftree-vectorize -fno-strict-overflow -mtune=${CPUTYPE}
                                        -maltivec
      )
    elseif(CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 4.0)
      target_compile_options(
        common_compiler_flags INTERFACE -ftree-vectorize -mtune=${CPUTYPE} -maltivec
      )
    elseif(CMAKE_C_COMPILER_VERSION VERSION_LESS 3.0)
      message(
        WARNING
          "GCC version ${CMAKE_C_COMPILER_VERSION} is too old for ppc64. Try GCC 3.0 or newer."
      )
    endif()
    # else()
    #   message(FATAL_ERROR "Unsupported compiler (${CMAKE_C_COMPILER_ID}) for ppc64. Try GCC.")
  endif()
endif()
