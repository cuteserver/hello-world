#
# Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
# All rights reserved
#

include(../CMake/Cute.cmake)
cute_add_library(MyStaticLibrary STATIC)
target_sources(MyStaticLibrary PRIVATE
               HelloTextInternal.cpp
               HelloTextInternal.h)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core REQUIRED)
target_link_libraries(MyStaticLibrary PRIVATE
                      Qt${QT_VERSION_MAJOR}::Core)
