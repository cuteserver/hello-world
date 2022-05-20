#
# Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
# All rights reserved
#


cmake_minimum_required (VERSION 3.18)
project(HelloWorld)

enable_language(CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

add_subdirectory(App)

if (NOT WASM)
    add_subdirectory(SharedLibrary)
    add_subdirectory(StaticLibrary)
endif()
