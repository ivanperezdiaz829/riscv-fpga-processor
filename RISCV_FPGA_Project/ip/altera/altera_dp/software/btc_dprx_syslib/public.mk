#------------------------------------------------------------------------------
#                    Library "PUBLIC" makefile fragment
#
# This file is intended to be included in an application or library
# makefile that is using this library.
#
# The following variables must be defined before including this file:
#
#     ALT_LIBRARY_ROOT_DIR
#         Contains the path to the library top-level (aka root) directory
#------------------------------------------------------------------------------

#START GENERATED

# The following TYPE comment allows tools to identify the 'type' of target this 
# makefile is associated with. 
# TYPE: LIB_PUBLIC_MAKEFILE

# This following VERSION comment indicates the version of the tool used to 
# generate this makefile. A makefile variable is provided for VERSION as well. 
# ACDS_VERSION: 13.1
ACDS_VERSION := 13.1

# This following BUILD_NUMBER comment indicates the build number of the tool 
# used to generate this makefile. 
# BUILD_NUMBER: 131

# List of include directories for -I compiler option (-I added when used).
ALT_INCLUDE_DIRS += $(ALT_LIBRARY_ROOT_DIR)/../btc_dprx_syslib

# Library directory for -L linker option (-L added when used).
ALT_LIBRARY_DIRS += $(ALT_LIBRARY_ROOT_DIR)

# Library name for -l linker option (-l added when used).
ALT_LIBRARY_NAMES += btc_dprx_syslib

# Library dependencies for the linker.
# This is the full pathname of the library (*.a) file.
ALT_LDDEPS += $(ALT_LIBRARY_ROOT_DIR)/libbtc_dprx_syslib.a

# This library supports running make to build it.
#MAKEABLE_LIBRARY_ROOT_DIRS += $(ALT_LIBRARY_ROOT_DIR)

#END GENERATED
