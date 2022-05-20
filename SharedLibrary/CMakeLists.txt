#
# Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
# All rights reserved
#

include(../CMake/Cute.cmake)

if (APPLE_MACOSX OR APPLE_IOS_DEVICE OR APPLE_IOS_SIMULATOR)
    set(FRAMEWORK True)
    set(MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0.0)
    set(MACOSX_FRAMEWORK_IDENTIFIER com.cute.test.shared_library)
    set(MACOSX_FRAMEWORK_SHORT_VERSION_STRING A)
endif()

if (APPLE_IOS_DEVICE OR APPLE_IOS_SIMULATOR)
    cute_add_library(MySharedLibrary SHARED)
else()
    cute_add_library(MySharedLibrary SHARED)
endif()
target_sources(MySharedLibrary PRIVATE
               HelloText.cpp
               HelloText.h
               HelloTextGlobals.h)
add_dependencies(MySharedLibrary MyStaticLibrary)

target_compile_definitions(MySharedLibrary PRIVATE HELLOWORLD_LIBRARY)

find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core REQUIRED)
target_link_libraries(MySharedLibrary PRIVATE
                      MyStaticLibrary
                      Qt${QT_VERSION_MAJOR}::Core)
