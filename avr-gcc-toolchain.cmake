##########################################################################
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Copyright (c) 2016 Igor Mikolic-Torreira
#
# Inspired in part by cmake toolchains created by
#   - Tomasz Bogdal (@queezythegreat on GitHub)
#   - Matthias Kleemann (@mkleemann on GitHub)
#
##########################################################################

##########################################################################
# The toolchain requires some variables set.
#
# AVR_MCU (default: atmega328p)
#     the type of AVR the application is built for
# AVR_MCU_SPEED (default: 16000000UL = 16 MHz)
#     the speed in MHz of the AVR MCU
# AVR_UPLOADTOOL (default: avrdude)
#     the application used to upload to the MCU
# AVR_UPLOADTOOL_PORT (default: usb)
#     the port used for the upload tool, e.g. usb
# AVR_PROGRAMMER (default: wiring)
#     the programmer hardware used, e.g. wiring
##########################################################################

##########################################################################
# options
##########################################################################
option( WITH_MCU "Add the MCU type to the target file name." OFF )


##########################################################################
# executables in use
##########################################################################
find_program( AVR_CC avr-gcc )
find_program( AVR_CXX avr-g++ )
find_program( AVR_OBJCOPY avr-objcopy )
find_program( AVR_SIZE_TOOL avr-size )
find_program( AVR_OBJDUMP avr-objdump )
find_program( AWK awk )


##########################################################################
# toolchain starts with defining mandatory variables
##########################################################################
set( CMAKE_SYSTEM_NAME Generic )
set( CMAKE_SYSTEM_PROCESSOR avr )
set( CMAKE_C_COMPILER ${AVR_CC} )
set( CMAKE_CXX_COMPILER ${AVR_CXX} )


###########################################################################
# some cmake cross-compile necessities
##########################################################################
if( DEFINED ENV{AVR_FIND_ROOT_PATH} )
    set( CMAKE_FIND_ROOT_PATH $ENV{AVR_FIND_ROOT_PATH} )
else( DEFINED ENV{AVR_FIND_ROOT_PATH} )
    if( EXISTS "/opt/local/avr" )
      set( CMAKE_FIND_ROOT_PATH "/opt/local/avr" )
    elseif( EXISTS "/usr/avr" )
      set( CMAKE_FIND_ROOT_PATH "/usr/avr" )
    elseif( EXISTS "/usr/lib/avr" )
      set( CMAKE_FIND_ROOT_PATH "/usr/lib/avr" )
    else( EXISTS "/opt/local/avr" )
      message( FATAL_ERROR "Please set AVR_FIND_ROOT_PATH in your environment." )
    endif( EXISTS "/opt/local/avr" )
endif( DEFINED ENV{AVR_FIND_ROOT_PATH} )
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
# not added automatically, since CMAKE_SYSTEM_NAME is "generic"
set( CMAKE_SYSTEM_INCLUDE_PATH "${CMAKE_FIND_ROOT_PATH}/include" )
set( CMAKE_SYSTEM_LIBRARY_PATH "${CMAKE_FIND_ROOT_PATH}/lib" )


##########################################################################
# status messages for generating
##########################################################################
message( STATUS "Set CMAKE_FIND_ROOT_PATH to ${CMAKE_FIND_ROOT_PATH}" )
message( STATUS "Set CMAKE_SYSTEM_INCLUDE_PATH to ${CMAKE_SYSTEM_INCLUDE_PATH}" )
message( STATUS "Set CMAKE_SYSTEM_LIBRARY_PATH to ${CMAKE_SYSTEM_LIBRARY_PATH}" )


#########################################################################
# some necessary tools and variables for AVR builds, which may not
# defined yet
# - AVR_UPLOADTOOL
# - AVR_UPLOADTOOL_PORT
# - AVR_PROGRAMMER
# - AVR_MCU
# - AVR_SIZE_ARGS
##########################################################################

# default upload tool
if( NOT AVR_UPLOADTOOL )
   set(
      AVR_UPLOADTOOL avrdude
      CACHE STRING "Set default upload tool: avrdude"
   )
   find_program( AVR_UPLOADTOOL avrdude )
endif( NOT AVR_UPLOADTOOL )

# default upload tool port
if( NOT AVR_UPLOADTOOL_PORT )
   set(
      AVR_UPLOADTOOL_PORT usb
      CACHE STRING "Set default upload tool port: usb"
   )
endif( NOT AVR_UPLOADTOOL_PORT )

# default programmer (hardware)
if( NOT AVR_PROGRAMMER )
   set(
      AVR_PROGRAMMER wiring
      CACHE STRING "Set default programmer hardware model: wiring"
   )
endif( NOT AVR_PROGRAMMER )

# default programmer upload speed
if( NOT AVR_UPLOAD_SPEED )
   set(
      AVR_UPLOAD_SPEED 115200
      CACHE STRING "Set default AVR_UPLOAD_SPEED: 115200 baud"
   )
endif( NOT AVR_UPLOAD_SPEED )

# default MCU (chip)
if( NOT AVR_MCU )
   set(
      AVR_MCU atmega328p
      CACHE STRING "Set default MCU: atmega328p (see 'avr-gcc --target-help' for valid values)"
   )
endif( NOT AVR_MCU )

# default MCU speed
if( NOT AVR_MCU_SPEED )
    set(
       AVR_MCU_SPEED 16000000UL
       CACHE STRING "Set default MCU SPEED: 16000000UL"
    )
endif( NOT AVR_MCU_SPEED )

# default avr-size args
if( NOT AVR_SIZE_ARGS )
    set( AVR_SIZE_ARGS -C;--mcu=${AVR_MCU} )
endif( NOT AVR_SIZE_ARGS )

# Prep avrdude special options
if( AVR_UPLOADTOOL MATCHES avrdude )
    set( AVR_UPLOADTOOL_OPTIONS -b${AVR_UPLOAD_SPEED} -D -V )
endif( AVR_UPLOADTOOL MATCHES avrdude )

# Set the awk arguments
#set( AWK_ARGS -f firmwaresize.awk )



##########################################################################
# set default compiler options:
##########################################################################
set( CMAKE_CXX_FLAGS "-fno-exceptions"  CACHE STRING "Default C++ flags for all builds" FORCE )

set( CMAKE_C_FLAGS_RELEASE "-O3 -Wall" CACHE STRING "Default C flags for release" FORCE )
set( CMAKE_CXX_FLAGS_RELEASE "-O3 -Wall" CACHE STRING "Default C++ flags for release" FORCE )

set( CMAKE_C_FLAGS_MINSIZEREL "-Os -mcall-prologues -Wall" CACHE STRING "Default C flags for minimum size release" FORCE )
set( CMAKE_CXX_FLAGS_MINSIZEREL "-Os -mcall-prologues -Wall" CACHE STRING "Default C++ flags for minimum size release" FORCE )

set( CMAKE_C_FLAGS_DEBUG "-g -Wall" CACHE STRING "Default C flags for debug" FORCE )
set( CMAKE_CXX_FLAGS_DEBUG "-g -Wall" CACHE STRING "Default C++ flags for debug" FORCE )

set( CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -g -Wall" CACHE STRING "Default C flags for release with debug info" FORCE )
set( CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -g -Wall" CACHE STRING "Default C++ flags for release with debug info" FORCE )



##########################################################################
# check build types:
# - Debug
# - Release
# - MinSizeRel
# - RelWithDebInfo
#
# Release is chosen, because of some optimized functions in the
# AVR toolchain, e.g. _delay_ms().
##########################################################################
if( NOT ( (CMAKE_BUILD_TYPE MATCHES Release) OR
        (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo) OR
        (CMAKE_BUILD_TYPE MATCHES Debug) OR
        (CMAKE_BUILD_TYPE MATCHES MinSizeRel) ) )
   set(
      CMAKE_BUILD_TYPE Release
      CACHE STRING "Choose cmake build type: Debug Release RelWithDebInfo MinSizeRel"
      FORCE
   )
endif( NOT ( (CMAKE_BUILD_TYPE MATCHES Release) OR
           (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo) OR
           (CMAKE_BUILD_TYPE MATCHES Debug) OR
           (CMAKE_BUILD_TYPE MATCHES MinSizeRel) ) )




##########################################################################
# target file name add-on
##########################################################################
if( WITH_MCU )
   set( MCU_TYPE_FOR_FILENAME "-${AVR_MCU}" )
else( WITH_MCU )
   set( MCU_TYPE_FOR_FILENAME "" )
endif( WITH_MCU )


##########################################################################
# status messages
##########################################################################
message( STATUS "Current uploadtool is: ${AVR_UPLOADTOOL}" )
message( STATUS "Current programmer is: ${AVR_PROGRAMMER}" )
message( STATUS "Current upload port is: ${AVR_UPLOADTOOL_PORT}" )
message( STATUS "Current uploadtool options are: ${AVR_UPLOADTOOL_OPTIONS}" )
message( STATUS "Current AVR MCU is set to: ${AVR_MCU}" )
message( STATUS "Current AVR MCU speed is set to: ${AVR_MCU_SPEED}" )




##########################################################################
# add_avr_executable
# - IN_VAR: EXECUTABLE_NAME
#
# Creates targets and dependencies for AVR toolchain, building an
# executable. Calls add_executable with ELF file as target name, so
# any link dependencies need to be using that target, e.g. for
# target_link_libraries(<EXECUTABLE_NAME>-${AVR_MCU}.elf ...).
##########################################################################

function( add_avr_executable EXECUTABLE_NAME )

   if( NOT ARGN )
      message( FATAL_ERROR "No source files given for ${EXECUTABLE_NAME}." )
   endif( NOT ARGN )

   # set file names
   set( elf_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.elf )
   set( hex_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.hex )
   set( map_file ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}.map )
   set( eeprom_image ${EXECUTABLE_NAME}${MCU_TYPE_FOR_FILENAME}-eeprom.hex )

   # elf file
   add_executable( ${elf_file} EXCLUDE_FROM_ALL ${ARGN} )

   target_compile_options(
        ${elf_file} PUBLIC
        -ffunction-sections
        -fdata-sections
        -fpack-struct
        -fshort-enums
        -funsigned-char
        -funsigned-bitfields
        -mmcu=${AVR_MCU}
        -DF_CPU=${AVR_MCU_SPEED}
   )

   target_link_libraries(
        ${elf_file} "-mmcu=${AVR_MCU} -Wl,--gc-sections -mrelax -Wl,-Map,${map_file}"
    )

   add_custom_command(
      OUTPUT ${hex_file}
      COMMAND
         ${AVR_OBJCOPY} -j .text -j .data -O ihex ${elf_file} ${hex_file}
      COMMAND
         ${AVR_SIZE_TOOL} ${AVR_SIZE_ARGS} ${elf_file} "|" ${AWK} -f firmwaresize_${EXECUTABLE_NAME}.awk
      DEPENDS ${elf_file} firmwaresize_${EXECUTABLE_NAME}.awk
   )

   # eeprom
   add_custom_command(
      OUTPUT ${eeprom_image}
      COMMAND
         ${AVR_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load
            --change-section-lma .eeprom=0 --no-change-warnings
            -O ihex ${elf_file} ${eeprom_image}
      DEPENDS ${elf_file}
   )

   add_custom_target(
      ${EXECUTABLE_NAME}
      ALL
      DEPENDS ${hex_file} ${eeprom_image}
   )

   set_target_properties(
      ${EXECUTABLE_NAME}
      PROPERTIES
         OUTPUT_NAME "${elf_file}"
   )

   # clean
   get_directory_property( clean_files ADDITIONAL_MAKE_CLEAN_FILES )
   set_directory_properties(
      PROPERTIES
         ADDITIONAL_MAKE_CLEAN_FILES "${map_file}"
   )

   # upload - with avrdude
   add_custom_target(
      upload_${EXECUTABLE_NAME}
      ${AVR_UPLOADTOOL} -p ${AVR_MCU} -c ${AVR_PROGRAMMER} ${AVR_UPLOADTOOL_OPTIONS}
         -U flash:w:${hex_file}
         -P ${AVR_UPLOADTOOL_PORT}
      DEPENDS ${hex_file}
      COMMENT "Uploading ${hex_file} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
   )

   # upload eeprom only - with avrdude
   # see also bug http://savannah.nongnu.org/bugs/?40142
   add_custom_target(
      upload_eeprom_${EXECUTABLE_NAME}
      ${AVR_UPLOADTOOL} -p ${AVR_MCU} -c ${AVR_PROGRAMMER} ${AVR_UPLOADTOOL_OPTIONS}
         -U eeprom:w:${eeprom_image}
         -P ${AVR_UPLOADTOOL_PORT}
      DEPENDS ${eeprom_image}
      COMMENT "Uploading ${eeprom_image} to ${AVR_MCU} using ${AVR_PROGRAMMER}"
   )

   # get status
   add_custom_target(
      get_status_${EXECUTABLE_NAME}
      ${AVR_UPLOADTOOL} -p ${AVR_MCU} -c ${AVR_PROGRAMMER} -P ${AVR_UPLOADTOOL_PORT} -n -v
      COMMENT "Get status from ${AVR_MCU}"
   )

   # disassemble
   add_custom_target(
      disassemble_${EXECUTABLE_NAME}
      ${AVR_OBJDUMP} -h -S ${elf_file} > ${EXECUTABLE_NAME}.lst
      DEPENDS ${elf_file}
   )

   # size
   add_custom_target(
      size_${EXECUTABLE_NAME}
         ${AVR_SIZE_TOOL} ${AVR_SIZE_ARGS} ${elf_file}  "|" ${AWK} -f firmwaresize_${EXECUTABLE_NAME}.awk
      DEPENDS ${elf_file} firmwaresize_${EXECUTABLE_NAME}.awk
   )

   add_custom_target(
      firmwaresize_${EXECUTABLE_NAME}.awk
      COMMAND
        echo "BEGIN {ORS=\"\";print \"\\\\n\\\\033[1;33mFirmware size (\"}" > firmwaresize_${EXECUTABLE_NAME}.awk
      COMMAND
        echo "/^Device/ {print \$2 \") is...  \"}" >> firmwaresize_${EXECUTABLE_NAME}.awk
      COMMAND
        echo "/^Program/ {print \"Flash (program): \" \$2 \" \" \$3 \" \" \$4 \")  \"}" >> firmwaresize_${EXECUTABLE_NAME}.awk
      COMMAND
        echo "/^Data/ {print \"RAM\ (globals): \" \$2 \" \" \$3 \" \" \$4 \")  \"}" >> firmwaresize_${EXECUTABLE_NAME}.awk
      COMMAND
        echo "END {print \"\\\\033[0m\\\\n\\\\n\"}" >> firmwaresize_${EXECUTABLE_NAME}.awk
      VERBATIM
   )

endfunction( add_avr_executable )





##########################################################################
# add_avr_library
# - IN_VAR: LIBRARY_NAME
#
# Calls add_library with an optionally concatenated name
# <LIBRARY_NAME>${MCU_TYPE_FOR_FILENAME}.
# This needs to be used for linking against the library, e.g. calling
# target_link_libraries(...).
##########################################################################

function( add_avr_library LIBRARY_NAME )

   if( NOT ARGN )
      message( FATAL_ERROR "No source files given for ${LIBRARY_NAME}." )
   endif( NOT ARGN )

   set( lib_file ${LIBRARY_NAME}${MCU_TYPE_FOR_FILENAME} )

   add_library( ${lib_file} STATIC ${ARGN} )

   set_target_properties(
      ${lib_file}
      PROPERTIES
         OUTPUT_NAME "${lib_file}"
   )

   target_compile_options( ${lib_file} PUBLIC
        -ffunction-sections
        -fdata-sections
        -fpack-struct
        -fshort-enums
        -funsigned-char
        -funsigned-bitfields
        -mmcu=${AVR_MCU}
        -DF_CPU=${AVR_MCU_SPEED}
   )

   if( NOT TARGET ${LIBRARY_NAME} )
      add_custom_target(
         ${LIBRARY_NAME}
         ALL
         DEPENDS ${lib_file}
      )

      set_target_properties(
         ${LIBRARY_NAME}
         PROPERTIES
            OUTPUT_NAME "${lib_file}"
      )
   endif( NOT TARGET ${LIBRARY_NAME} )

endfunction( add_avr_library )







##########################################################################
# avr_target_link_libraries
# - IN_VAR: EXECUTABLE_TARGET
# - ARGN  : targets and files to link to
#
# Calls target_link_libraries with AVR target names (concatenation,
# extensions and so on.
##########################################################################

function( avr_target_link_libraries EXECUTABLE_TARGET )

   if( NOT ARGN )
      message( FATAL_ERROR "Nothing to link to ${EXECUTABLE_TARGET}." )
   endif( NOT ARGN )

   get_target_property( TARGET_LIST ${EXECUTABLE_TARGET} OUTPUT_NAME )

   foreach( TGT ${ARGN} )
      if( TARGET ${TGT} )
         get_target_property( ARG_NAME ${TGT} OUTPUT_NAME )
         list( APPEND TARGET_LIST ${ARG_NAME} )
      else( TARGET ${TGT} )
         list( APPEND NON_TARGET_LIST ${TGT} )
      endif( TARGET ${TGT} )
   endforeach( TGT ${ARGN} )

   target_link_libraries( ${TARGET_LIST} ${NON_TARGET_LIST} )

endfunction( avr_target_link_libraries EXECUTABLE_TARGET )
