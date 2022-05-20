#
# Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
# All rights reserved
#

#
# This is the Cute Server`s (https://cuteserver.io) toolchain file used to build
# Qt-based projects for the Desktop, Android, iOS and WebAssembly
#

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
#
# Variables used by all targets (Android, iOS, WebAssembly)
#
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES QT_SDK_DIR)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES QT_HOST_PATH)
#
# Variables used by iOS target that should be propagated
# when compiling test projects
#
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES APPLE_IOS_TARGET)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES APPLE_IOS_DEVICE)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES APPLE_IOS_SIMULATOR)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES MIN_IOS_SDK_TARGET)
#
# Variables used by Android target that should be propagated
# when compiling test projects
#
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_CPP_FEATURES)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_TARGET)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_SDK)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_NDK)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_ABIS)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_MIN_SDK_VERSION)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_TARGET_SDK_VERSION)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ANDROID_ABI)
#
# Variables used by WebAssembly target that should be propagated
# when compiling test projects
#
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES WASM_TARGET)
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES WASM_SDK)

macro (save_var VAR)
    set(ENV{${VAR}} "${${VAR}}")
endmacro()

macro (load_var VAR)
    if (NOT DEFINED ENV{${VAR}})
        message(FATAL_ERROR "${VAR} is not defined.")
    else()
        set(${VAR} "$ENV{${VAR}}")
    endif()
endmacro()

macro (save_optional_var VAR)
    set(ENV{${VAR}} "${${VAR}}")
endmacro()

macro (load_optional_var VAR)
    if (NOT DEFINED ENV{${VAR}})
        unset(${VAR})
    else()
        set(${VAR} "$ENV{${VAR}}")
    endif()
endmacro()

if (NOT DEFINED ENV{HAS_ALREADY_RUN_CMAKE_TOOLCHAIN_FILE_ENV_VAR})
    set(IS_FIRST_RUN True)
    set(ENV{HAS_ALREADY_RUN_CMAKE_TOOLCHAIN_FILE_ENV_VAR} True)
else()
    set(IS_FIRST_RUN False)
endif()

if (IS_FIRST_RUN)
    if (DEFINED QT_HOST_PATH)
        save_optional_var(QT_HOST_PATH)
    endif()
    if (DEFINED ANDROID_TARGET)
        set(TOOLCHAIN_TARGET_TYPE "ANDROID_TARGET")
        save_var(TOOLCHAIN_TARGET_TYPE)
        message("Configuring toolchain for Android build.")
        if (NOT DEFINED ANDROID_SDK)
            message(FATAL_ERROR "ANDROID_SDK must be defined with the directory where Android SDK has been installed.")
        else()
            save_var(ANDROID_SDK)
        endif()
        if (NOT DEFINED ANDROID_NDK)
            message(FATAL_ERROR "ANDROID_NDK must be defined with the directory where Android NDK has been installed.")
        else()
            save_var(ANDROID_NDK)
        endif()
        if (NOT DEFINED ANDROID_ABIS)
            message(FATAL_ERROR "ANDROID_ABIS must be defined with the Android abis to build for and formatted as a string with semicolon-separated abis (ANDROID_ABIS=armeabi-v7a;arm64-v8a;x86;x86_64.")
        else()
            if ("${ANDROID_ABIS}" STREQUAL "" OR NOT DEFINED ANDROID_ABIS)
                message(FATAL_ERROR "ANDROID_ABIS must be defined with the Android abis to build for and formatted as a string with semicolon-separated abis (ANDROID_ABIS=armeabi-v7a;arm64-v8a;x86;x86_64.")
            endif()
            save_var(ANDROID_ABIS)
        endif()
        #
        # Fetching directory of all ABIs specified by ANDROID_ABIS
        #
        # QT_SDK_DIR should point to a directory containing the android folders.
        # fetching the list of folders:
        file(GLOB QT_ANDROID_DIRS LIST_DIRECTORIES true RELATIVE ${QT_SDK_DIR} ${QT_SDK_DIR}/*)
        foreach(QT_ANDROID_DIR ${QT_ANDROID_DIRS})
            if (${QT_ANDROID_DIR} STREQUAL android)
                if (IS_FIRST_RUN)
                    message("Using ${QT_SDK_DIR}/android for all abis")
                endif()
                set(ANDROID_SDK_DIR_armeabi-v7a ${QT_SDK_DIR}/${QT_ANDROID_DIR})
                set(ANDROID_SDK_DIR_arm64-v8a ${QT_SDK_DIR}/${QT_ANDROID_DIR})
                set(ANDROID_SDK_DIR_x86 ${QT_SDK_DIR}/${QT_ANDROID_DIR})
                set(ANDROID_SDK_DIR_x86_64 ${QT_SDK_DIR}/${QT_ANDROID_DIR})
                break()
            elseif ((${QT_ANDROID_DIR} STREQUAL android_armeabi-v7a) OR (${QT_ANDROID_DIR} STREQUAL android_armv7))
                set(ANDROID_SDK_DIR_armeabi-v7a ${QT_SDK_DIR}/${QT_ANDROID_DIR})
            elseif ((${QT_ANDROID_DIR} STREQUAL android_arm64-v8a) OR (${QT_ANDROID_DIR} STREQUAL android_arm64_v8a))
                set(ANDROID_SDK_DIR_arm64-v8a ${QT_SDK_DIR}/${QT_ANDROID_DIR})
            elseif (${QT_ANDROID_DIR} STREQUAL android_x86)
                set(ANDROID_SDK_DIR_x86 ${QT_SDK_DIR}/${QT_ANDROID_DIR})
            elseif (${QT_ANDROID_DIR} STREQUAL android_x86_64)
                set(ANDROID_SDK_DIR_x86_64 ${QT_SDK_DIR}/${QT_ANDROID_DIR})
            endif ()
        endforeach()
        save_optional_var(ANDROID_SDK_DIR_armeabi-v7a)
        save_optional_var(ANDROID_SDK_DIR_arm64-v8a)
        save_optional_var(ANDROID_SDK_DIR_x86)
        save_optional_var(ANDROID_SDK_DIR_x86_64)
        list(GET ANDROID_ABIS 0 MAIN_ANDROID_ABI)
        if(NOT DEFINED ANDROID_ABI)
            message("Setting ANDROID_ABI to ${MAIN_ANDROID_ABI}")
            set(ANDROID_ABI ${MAIN_ANDROID_ABI})
        endif()
        save_var(ANDROID_ABI)
        set(CMAKE_SHARED_MODULE_SUFFIX_CXX "_${ANDROID_ABI}.so")
        set(CMAKE_SHARED_LIBRARY_SUFFIX_CXX "_${ANDROID_ABI}.so")
        set(CMAKE_STATIC_LIBRARY_SUFFIX_CXX "_${ANDROID_ABI}.a")
        set(CMAKE_SHARED_MODULE_SUFFIX_C "_${ANDROID_ABI}.so")
        set(CMAKE_SHARED_LIBRARY_SUFFIX_C "_${ANDROID_ABI}.so")
        set(CMAKE_STATIC_LIBRARY_SUFFIX_C "_${ANDROID_ABI}.a")
        message("Cross-compiling for Android ${ANDROID_ABI}")
        if (DEFINED ANDROID_CPP_FEATURES)
            save_optional_var(ANDROID_CPP_FEATURES)
        endif()
        if (NOT DEFINED QT_SDK_DIR)
            message(FATAL_ERROR "QT_SDK_DIR must be defined as the directory containing Qt's android installation folder(s).")
        else()
            save_var(QT_SDK_DIR)
        endif()
        find_package(Java COMPONENTS Development)
        if (NOT Java_Development_FOUND)
            message(FATAL_ERROR "Failed to find java.")
        else()
            set(JAVA_EXE ${Java_JAVA_EXECUTABLE})
            save_var(JAVA_EXE)
            get_filename_component(JDK_DIR ${Java_JAVA_EXECUTABLE} DIRECTORY)
            get_filename_component(JDK_DIR ${JDK_DIR}/.. ABSOLUTE)
            save_var(JDK_DIR)
        endif()
        set(ANDROID_DEPLOYMENT_SETTINGS_FILE "${CMAKE_CURRENT_LIST_DIR}/android_deployment_settings.json.in")
        save_var(ANDROID_DEPLOYMENT_SETTINGS_FILE)
    elseif (DEFINED APPLE_IOS_TARGET)
        if (DEFINED ANDROID_TARGET)
            message(FATAL_ERROR "ANDROID_TARGET and APPLE_IOS_TARGET defined! When configuring using Cute toolchain, only one target can be defined.")
        endif()
        set(TOOLCHAIN_TARGET_TYPE "APPLE_IOS_TARGET")
        save_var(TOOLCHAIN_TARGET_TYPE)
        message("Configuring toolchain for Apple iOS build.")
        if (DEFINED APPLE_IOS_DEVICE AND DEFINED APPLE_IOS_SIMULATOR)
            message(FATAL_ERROR "Either APPLE_IOS_DEVICE or APPLE_IOS_SIMULATOR must be set to true but not both.")
        elseif (NOT DEFINED APPLE_IOS_DEVICE AND NOT DEFINED APPLE_IOS_SIMULATOR)
            message(FATAL_ERROR "Either APPLE_IOS_DEVICE or APPLE_IOS_SIMULATOR must be set to true.")
        elseif(DEFINED APPLE_IOS_DEVICE)
            set(APPLE_IOS_DEVICE True)
            set(APPLE_IOS_SIMULATOR False)
            set(PLATFORM_NAME iphoneos)
        elseif(DEFINED APPLE_IOS_SIMULATOR)
            set(APPLE_IOS_SIMULATOR True)
            set(APPLE_IOS_DEVICE False)
            set(PLATFORM_NAME iphonesimulator)
        endif()
        save_var(APPLE_IOS_DEVICE)
        save_var(APPLE_IOS_SIMULATOR)
        save_var(PLATFORM_NAME)
        save_optional_var(MIN_IOS_SDK_TARGET)
        if (NOT DEFINED QT_SDK_DIR)
            message(FATAL_ERROR "QT_SDK_DIR must be defined as the directory containing Qt's iOS installation directory.")
        else()
            save_var(QT_SDK_DIR)
        endif()
        #
        # Qt is built as static libraries on iOS. Thus, to prevent the linker from discarding the
        # plugins, which are also static libraries, the Q_IMPORT_PLUGIN must be used to create a
        # dependency on the plugin at compile time. Here we will list all static libraries in
        # the plugin and qml directories and will fetch all plugin names from those static libraries.
        # Plugins have a function named qt_static_plugin_PLUGIN_NAME. The nm executable can be used
        # to list all functions:
        # nm --just-symbol-name -g STATIC_LIB_FILE_PATH | grep qt_static_plugin
        #
        macro(cute_fetch_qt_plugins PLUGINS_DIR PLUGINS_NAMES_LIST_VAL PLUGINS_LIBS_LIST_VAL)
            if (NOT IS_DIRECTORY ${PLUGINS_DIR})
                message(FATAL_ERROR "Failed to fetch Qt plugins ${PLUGINS_DIR} is not a directory.")
            else()
                message("Fetching Qt plugins located at ${PLUGINS_DIR}.")
            endif()
            string(TOLOWER ${CMAKE_BUILD_TYPE} build_type_lower)
            file(GLOB_RECURSE CUTE_QT_PLUGINS ${PLUGINS_DIR}/*.a)
            foreach(current_entry ${CUTE_QT_PLUGINS})
                if ("${build_type_lower}" STREQUAL "debug")
                    string(REGEX MATCH "^.*_debug\\.a" PLUGIN_LIBRARY ${current_entry})
                else()
                    string(REGEX MATCH "^.*\\.a" PLUGIN_LIBRARY ${current_entry})
                    string(REGEX MATCH "^.*_debug\\.a" PLUGIN_LIBRARY_DEBUG ${PLUGIN_LIBRARY})
                    if (NOT ("${PLUGIN_LIBRARY_DEBUG}" STREQUAL ""))
                        set(PLUGIN_LIBRARY "")
                    endif()
                endif()
                if (NOT ("${PLUGIN_LIBRARY}" STREQUAL ""))
                    execute_process(COMMAND
                                    nm --just-symbol-name -g ${PLUGIN_LIBRARY}
                                    COMMAND
                                    grep qt_static_plugin
                                    OUTPUT_STRIP_TRAILING_WHITESPACE
                                    OUTPUT_VARIABLE
                                    MANGLED_PLUGIN_FUNCTION_NAMES
                                    ERROR_QUIET)
                    if (NOT ("${MANGLED_PLUGIN_FUNCTION_NAMES}" STREQUAL ""))
                        string (REPLACE "\n" ";" MANGLED_PLUGIN_FUNCTION_NAMES "${MANGLED_PLUGIN_FUNCTION_NAMES}")
                        foreach(mangled_name ${MANGLED_PLUGIN_FUNCTION_NAMES})
                            execute_process(COMMAND
                                            c++filt ${mangled_name}
                                            OUTPUT_STRIP_TRAILING_WHITESPACE
                                            OUTPUT_VARIABLE
                                            DEMANGLED_PLUGIN_FUNCTION_NAME
                                            ERROR_QUIET)
                            string(REGEX REPLACE "^.*qt_static_plugin_|[()]" "" PLUGIN_NAME "${DEMANGLED_PLUGIN_FUNCTION_NAME}")
                            if (NOT ("${PLUGIN_NAME}" STREQUAL ""))
                                list(APPEND PLUGINS_NAMES_LIST ${PLUGIN_NAME})
                                list(APPEND PLUGINS_LIBS_LIST ${PLUGIN_LIBRARY})
                            endif()
                        endforeach ()
                    endif()
                endif()
            endforeach()
            list(REMOVE_DUPLICATES PLUGINS_NAMES_LIST)
            set(${PLUGINS_NAMES_LIST_VAL} "${PLUGINS_NAMES_LIST}")
            list(REMOVE_DUPLICATES PLUGINS_LIBS_LIST)
            set(${PLUGINS_LIBS_LIST_VAL} "${PLUGINS_LIBS_LIST}")
        endmacro()
        if (NOT IS_DIRECTORY ${QT_SDK_DIR}/plugins)
            message(FATAL_ERROR "Qt plugins directory ${QT_SDK_DIR}/plugins does not exit.")
        elseif (NOT IS_DIRECTORY ${QT_SDK_DIR}/qml)
            message(FATAL_ERROR "Qt qml directory ${QT_SDK_DIR}/qml does not exit.")
        endif()
        cute_fetch_qt_plugins(${QT_SDK_DIR}/plugins CORE_PLUGINS_NAMES_LIST CORE_PLUGINS_LIBS_LIST)
        cute_fetch_qt_plugins(${QT_SDK_DIR}/qml QML_PLUGINS_NAMES_LIST QML_PLUGINS_LIBS_LIST)
        macro (cute_create_qt_import_plugins_cpp_file PLUGINS_NAMES_LIST FILE_PATH)
            file(WRITE ${FILE_PATH} "// file generated by Cute.toolchain.cmake\n\n")
            file(APPEND ${FILE_PATH} "#include <QtPlugin>\n\n")
            foreach(plugin_name ${${PLUGINS_NAMES_LIST}})
                file(APPEND ${FILE_PATH} "Q_IMPORT_PLUGIN(${plugin_name})\n")
            endforeach()
        endmacro()
        set(QT_IMPORT_PLUGINS_CPP_FILE "${CMAKE_BINARY_DIR}/generated/qt_import_plugins.cpp")
        cute_create_qt_import_plugins_cpp_file(CORE_PLUGINS_NAMES_LIST "${QT_IMPORT_PLUGINS_CPP_FILE}")
        set(QT_QML_IMPORT_PLUGINS_CPP_FILE "${CMAKE_BINARY_DIR}/generated/qt_qml_import_plugins.cpp")
        cute_create_qt_import_plugins_cpp_file(QML_PLUGINS_NAMES_LIST "${QT_QML_IMPORT_PLUGINS_CPP_FILE}")
        save_var(QT_IMPORT_PLUGINS_CPP_FILE)
        save_var(QT_QML_IMPORT_PLUGINS_CPP_FILE)
        save_var(CORE_PLUGINS_LIBS_LIST)
        save_var(QML_PLUGINS_LIBS_LIST)
        #
        # As Plugins depend upon Qt libraries, we will link to all of them.
        #
        string(TOLOWER ${CMAKE_BUILD_TYPE} build_type_lower)
        file(GLOB_RECURSE CUTE_QT_LIB_ENTRIES ${QT_SDK_DIR}/lib/*.a)
        foreach(current_entry ${CUTE_QT_LIB_ENTRIES})
            if ("${build_type_lower}" STREQUAL "debug")
                string(REGEX MATCH "^.*_debug\\.a" QT_LIB ${current_entry})
            else()
                string(REGEX MATCH "^.*\\.a" QT_LIB ${current_entry})
                string(REGEX MATCH "^.*_debug\\.a" QT_DEBUG_LIB ${QT_LIB})
                if (NOT ("${QT_DEBUG_LIB}" STREQUAL ""))
                    set(QT_LIB "")
                endif()
            endif()
            string(REGEX MATCH "^.*Qt5Bootstrap.*" QT_BOOTSTRAP_LIB "${QT_LIB}")
            if (NOT ("${QT_BOOTSTRAP_LIB}" STREQUAL ""))
                set(QT_LIB "")
            endif()
            string(REGEX MATCH "^.*Qt5QmlDevTools.*" QT_QMLDEVTOOLS_LIB "${QT_LIB}")
            if (NOT ("${QT_QMLDEVTOOLS_LIB}" STREQUAL ""))
                set(QT_LIB "")
            endif()
            if (NOT ("${QT_LIB}" STREQUAL ""))
                list(APPEND CUTE_QT_LIBS_LIST ${QT_LIB})
            endif()
        endforeach()
        save_var(CUTE_QT_LIBS_LIST)
        #
        # iOS apps must have a launch storyboard to make the app fullscreen.
        # here a default storyboard will be used.
        #
        set(DEFAULT_SPLASH_SCREEN_NAME "SplashScreen.storyboard")
        set(DEFAULT_SPLASH_SCREEN "${CMAKE_CURRENT_LIST_DIR}/${DEFAULT_SPLASH_SCREEN_NAME}")
        save_var(DEFAULT_SPLASH_SCREEN)
        set(DEFAULT_IOS_PLIST_FILE "${CMAKE_CURRENT_LIST_DIR}/iOSAppInfo.plist.in")
        save_var(DEFAULT_IOS_PLIST_FILE)
    endif()
    if (DEFINED WASM_TARGET)
        if (DEFINED APPLE_IOS_TARGET)
            message(FATAL_ERROR "WASM_TARGET and APPLE_IOS_TARGET defined! When configuring using Cute toolchain, only one target can be defined.")
        elseif (DEFINED ANDROID_TARGET)
            message(FATAL_ERROR "WASM_TARGET and ANDROID_TARGET defined! When configuring using Cute toolchain, only one target can be defined.")
        endif()
        set(TOOLCHAIN_TARGET_TYPE "WASM_TARGET")
        save_var(TOOLCHAIN_TARGET_TYPE)
        message("Configuring toolchain for WebAssembly.")
        if (NOT DEFINED QT_SDK_DIR)
            message(FATAL_ERROR "QT_SDK_DIR must be defined as the directory containing Qt's iOS installation directory.")
        else()
            save_var(QT_SDK_DIR)
        endif()
        if (NOT DEFINED WASM_SDK)
            message(FATAL_ERROR "WASM_SDK must be defined as the directory containing the Emscripten SDK installation.")
        else()
            save_var(WASM_SDK)
        endif()
        #
        # Qt is built as static libraries when targeting WebAssembly. Thus, to prevent the linker from discarding the
        # plugins, which are also static libraries, the Q_IMPORT_PLUGIN must be used to create a
        # dependency on the plugin at compile time. Here we will list all static libraries in
        # the plugin and qml directories and will fetch all plugin names from those static libraries.
        # Plugins have a function named qt_static_plugin_PLUGIN_NAME. On Linux/macOS, The nm executable can be used
        # to list all functions:
        # nm --just-symbol-name -g STATIC_LIB_FILE_PATH | grep qt_static_plugin
        #
        set(NM_EXE "${WASM_SDK}/bin/llvm-nm")
        set(CXX_FILT_EXT "${WASM_SDK}/bin/llvm-cxxfilt")
        if (NOT EXISTS "${NM_EXE}")
            message(FATAL_ERROR "Did not find nm executable. It is required to fetch Qt's plugins names.")
        endif()
        macro(cute_fetch_wasm_qt_plugins PLUGINS_DIR PLUGINS_NAMES_LIST_VAL PLUGINS_LIBS_LIST_VAL)
            if (NOT IS_DIRECTORY ${PLUGINS_DIR})
                message(FATAL_ERROR "Failed to fetch Qt plugins ${PLUGINS_DIR} is not a directory.")
            else()
                message("Fetching Qt plugins located at ${PLUGINS_DIR}.")
            endif()
            file(GLOB_RECURSE CUTE_QT_PLUGINS ${PLUGINS_DIR}/*.a)
            foreach(current_entry ${CUTE_QT_PLUGINS})
                string(REGEX MATCH "^.*\\.a" PLUGIN_LIBRARY ${current_entry})
                if (NOT ("${PLUGIN_LIBRARY}" STREQUAL ""))
                    execute_process(COMMAND
                                    ${NM_EXE} --just-symbol-name -g --demangle ${PLUGIN_LIBRARY}
                                    COMMAND
                                    grep qt_static_plugin
                                    OUTPUT_STRIP_TRAILING_WHITESPACE
                                    OUTPUT_VARIABLE
                                    MANGLED_PLUGIN_FUNCTION_NAMES
                                    ERROR_QUIET)
                    if (NOT ("${MANGLED_PLUGIN_FUNCTION_NAMES}" STREQUAL ""))
                        string (REPLACE "\n" ";" MANGLED_PLUGIN_FUNCTION_NAMES "${MANGLED_PLUGIN_FUNCTION_NAMES}")
                        foreach(mangled_name ${MANGLED_PLUGIN_FUNCTION_NAMES})
                            execute_process(COMMAND
                                            ${CXX_FILT_EXT} ${mangled_name}
                                            OUTPUT_STRIP_TRAILING_WHITESPACE
                                            OUTPUT_VARIABLE
                                            DEMANGLED_PLUGIN_FUNCTION_NAME
                                            ERROR_QUIET)
                            string(REGEX REPLACE "^.*qt_static_plugin_|[()]" "" PLUGIN_NAME "${DEMANGLED_PLUGIN_FUNCTION_NAME}")
                            if (NOT ("${PLUGIN_NAME}" STREQUAL ""))
                                list(APPEND PLUGINS_NAMES_LIST ${PLUGIN_NAME})
                                list(APPEND PLUGINS_LIBS_LIST ${PLUGIN_LIBRARY})
                            endif()
                        endforeach ()
                    endif()
                endif()
            endforeach()
            list(REMOVE_DUPLICATES PLUGINS_NAMES_LIST)
            set(${PLUGINS_NAMES_LIST_VAL} "${PLUGINS_NAMES_LIST}")
            list(REMOVE_DUPLICATES PLUGINS_LIBS_LIST)
            set(${PLUGINS_LIBS_LIST_VAL} "${PLUGINS_LIBS_LIST}")
        endmacro()
        if (NOT IS_DIRECTORY ${QT_SDK_DIR}/plugins)
            message(FATAL_ERROR "Qt plugins directory ${QT_SDK_DIR}/plugins does not exit.")
        elseif (NOT IS_DIRECTORY ${QT_SDK_DIR}/qml)
            message(FATAL_ERROR "Qt qml directory ${QT_SDK_DIR}/qml does not exit.")
        endif()
        cute_fetch_wasm_qt_plugins(${QT_SDK_DIR}/plugins CORE_PLUGINS_NAMES_LIST CORE_PLUGINS_LIBS_LIST)
        cute_fetch_wasm_qt_plugins(${QT_SDK_DIR}/qml QML_PLUGINS_NAMES_LIST QML_PLUGINS_LIBS_LIST)
        macro (cute_create_wasm_qt_import_plugins_cpp_file PLUGINS_NAMES_LIST FILE_PATH)
            file(WRITE ${FILE_PATH} "// file generated by Cute.toolchain.cmake\n\n")
            file(APPEND ${FILE_PATH} "#include <QtPlugin>\n\n")
            foreach(plugin_name ${${PLUGINS_NAMES_LIST}})
                file(APPEND ${FILE_PATH} "Q_IMPORT_PLUGIN(${plugin_name})\n")
            endforeach()
        endmacro()
        set(QT_IMPORT_PLUGINS_CPP_FILE "${CMAKE_BINARY_DIR}/generated/qt_import_plugins.cpp")
        cute_create_wasm_qt_import_plugins_cpp_file(CORE_PLUGINS_NAMES_LIST "${QT_IMPORT_PLUGINS_CPP_FILE}")
        set(QT_QML_IMPORT_PLUGINS_CPP_FILE "${CMAKE_BINARY_DIR}/generated/qt_qml_import_plugins.cpp")
        cute_create_wasm_qt_import_plugins_cpp_file(QML_PLUGINS_NAMES_LIST "${QT_QML_IMPORT_PLUGINS_CPP_FILE}")
        save_var(QT_IMPORT_PLUGINS_CPP_FILE)
        save_var(QT_QML_IMPORT_PLUGINS_CPP_FILE)
        save_var(CORE_PLUGINS_LIBS_LIST)
        save_var(QML_PLUGINS_LIBS_LIST)
        #
        # As Plugins depend upon Qt libraries, we will link to all of them.
        #
        file(GLOB_RECURSE CUTE_QT_LIB_ENTRIES ${QT_SDK_DIR}/lib/*.a)
        foreach(current_entry ${CUTE_QT_LIB_ENTRIES})
            string(REGEX MATCH "^.*\\.a" QT_LIB ${current_entry})
            string(REGEX MATCH "^.*Qt5Bootstrap.*" QT_BOOTSTRAP_LIB "${QT_LIB}")
            if (NOT ("${QT_BOOTSTRAP_LIB}" STREQUAL ""))
                set(QT_LIB "")
            endif()
            string(REGEX MATCH "^.*Qt5QmlDevTools.*" QT_QMLDEVTOOLS_LIB "${QT_LIB}")
            if (NOT ("${QT_QMLDEVTOOLS_LIB}" STREQUAL ""))
                set(QT_LIB "")
            endif()
            if (NOT ("${QT_LIB}" STREQUAL ""))
                list(APPEND CUTE_QT_LIBS_LIST ${QT_LIB})
            endif()
        endforeach()
        save_var(CUTE_QT_LIBS_LIST)
    endif()
    if (NOT DEFINED ANDROID_TARGET AND NOT DEFINED APPLE_IOS_TARGET AND NOT DEFINED WASM_TARGET)
        message(FATAL_ERROR "No target has been defined! Set either ANDROID_TARGET, APPLE_IOS_TARGET or WASM_TARGET to True.")
    endif()
else()
    message("Detecting toolchain target.")
    load_optional_var(QT_HOST_PATH)
    load_var(TOOLCHAIN_TARGET_TYPE)
    if ("${TOOLCHAIN_TARGET_TYPE}" STREQUAL "ANDROID_TARGET")
        message("Android target.")
        set(ANDROID_TARGET True)
        load_var(ANDROID_SDK)
        load_var(ANDROID_NDK)
        load_var(ANDROID_ABIS)
        load_var(ANDROID_ABI)
        load_optional_var(ANDROID_SDK_DIR_armeabi-v7a)
        load_optional_var(ANDROID_SDK_DIR_arm64-v8a)
        load_optional_var(ANDROID_SDK_DIR_x86)
        load_optional_var(ANDROID_SDK_DIR_x86_64)
        load_optional_var(ANDROID_CPP_FEATURES)
        load_var(QT_SDK_DIR)
        load_var(JAVA_EXE)
        load_var(JDK_DIR)
        load_var(ANDROID_DEPLOYMENT_SETTINGS_FILE)
    elseif("${TOOLCHAIN_TARGET_TYPE}" STREQUAL "APPLE_IOS_TARGET")
        message("Apple iOS target.")
        set(APPLE_IOS_TARGET True)
        load_var(APPLE_IOS_DEVICE)
        load_var(APPLE_IOS_SIMULATOR)
        load_var(PLATFORM_NAME)
        load_optional_var(MIN_IOS_SDK_TARGET)
        load_var(QT_SDK_DIR)
        load_var(QT_IMPORT_PLUGINS_CPP_FILE)
        load_var(QT_QML_IMPORT_PLUGINS_CPP_FILE)
        load_var(CORE_PLUGINS_LIBS_LIST)
        load_var(QML_PLUGINS_LIBS_LIST)
        load_var(CUTE_QT_LIBS_LIST)
        load_var(DEFAULT_SPLASH_SCREEN)
        load_var(DEFAULT_IOS_PLIST_FILE)
    elseif ("${TOOLCHAIN_TARGET_TYPE}" STREQUAL "WASM_TARGET")
        message("Wasm target.")
        set(WASM_TARGET True)
        set(WASM True)
        load_var(QT_SDK_DIR)
        load_var(WASM_SDK)
        load_var(QT_IMPORT_PLUGINS_CPP_FILE)
        load_var(QT_QML_IMPORT_PLUGINS_CPP_FILE)
        load_var(CORE_PLUGINS_LIBS_LIST)
        load_var(QML_PLUGINS_LIBS_LIST)
        load_var(CUTE_QT_LIBS_LIST)
    endif()
endif()

if (ANDROID_TARGET)
    if(NOT DEFINED ANDROID_MIN_SDK_VERSION)
        set(ANDROID_MIN_SDK_VERSION 21)
    endif()
    if(NOT DEFINED ANDROID_TARGET_SDK_VERSION)
        set(ANDROID_TARGET_SDK_VERSION 31)
    endif()
    if (NOT DEFINED ANDROID_PLATFORM)
        set(ANDROID_PLATFORM ${ANDROID_MIN_SDK_VERSION})
    endif()
    message("Loading ${ANDROID_NDK}/build/cmake/android.toolchain.cmake")
    include(${ANDROID_NDK}/build/cmake/android.toolchain.cmake)
elseif (APPLE_IOS_TARGET)
    if (APPLE_IOS_DEVICE)
        message("Cross-compiling for Apple iOS devices")
    elseif (APPLE_IOS_SIMULATOR)
        message("Cross-compiling for Apple iOS simulator")
    endif()
    #
    # Configuration here follows in part what is done in the file below:
    # See https://opensource.apple.com/source/clang/clang-800.0.38/src/cmake/platforms/iOS.cmake
    #
    if (NOT DEFINED PLATFORM_NAME)
        message(FATAL_ERROR "PLATFORM_NAME is not defined. It should be either iphoneos or iphonesimulator.")
    endif()
    if (IS_FIRST_RUN)
        message("Cross Compiling for Apple iOS")
        message("Querying XCode for SDK root")
    endif()
    execute_process(COMMAND xcodebuild -version -sdk ${PLATFORM_NAME} Path
                    OUTPUT_VARIABLE SDKROOT
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_OSX_SYSROOT ${SDKROOT})
    if (IS_FIRST_RUN)
        message("Set sysroot for ${PLATFORM_NAME} to ${SDKROOT}")
    endif()
    if ("${MIN_IOS_SDK_TARGET}" STREQUAL "")
        message("MIN_IOS_SDK_TARGET was not defined. Querying XCode for available SDK version...")
        execute_process(COMMAND xcodebuild -sdk ${SDKROOT} -version SDKVersion
                        OUTPUT_VARIABLE MIN_IOS_SDK_TARGET
                        ERROR_QUIET
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
    message("Set minimum iOS SDK version to ${MIN_IOS_SDK_TARGET}")
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find clang
                    OUTPUT_VARIABLE CMAKE_C_COMPILER
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (IS_FIRST_RUN)
        message(STATUS "Using C compiler ${CMAKE_C_COMPILER}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find clang++
                    OUTPUT_VARIABLE CMAKE_CXX_COMPILER
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (IS_FIRST_RUN)
        message(STATUS "Using C++ compiler ${CMAKE_CXX_COMPILER}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find ar
                    OUTPUT_VARIABLE CMAKE_AR_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_AR ${CMAKE_AR_val} CACHE FILEPATH "Archiver")
    if (IS_FIRST_RUN)
        message(STATUS "Using ar ${CMAKE_AR}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find ranlib
                    OUTPUT_VARIABLE CMAKE_RANLIB_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_RANLIB ${CMAKE_RANLIB_val} CACHE FILEPATH "Ranlib")
    if (IS_FIRST_RUN)
        message(STATUS "Using ranlib ${CMAKE_RANLIB}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find strip
                    OUTPUT_VARIABLE CMAKE_STRIP_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_STRIP ${CMAKE_STRIP_val} CACHE FILEPATH "Strip")
    if (IS_FIRST_RUN)
        message(STATUS "Using strip ${CMAKE_STRIP}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find dsymutil
                    OUTPUT_VARIABLE CMAKE_DSYMUTIL_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_DSYMUTIL ${CMAKE_DSYMUTIL_val} CACHE FILEPATH "Dsymutil")
    if (IS_FIRST_RUN)
        message(STATUS "Using dsymutil ${CMAKE_DSYMUTIL}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find libtool
                    OUTPUT_VARIABLE CMAKE_LIBTOOL_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_LIBTOOL ${CMAKE_LIBTOOL_val} CACHE FILEPATH "Libtool")
    if (IS_FIRST_RUN)
        message(STATUS "Using libtool ${CMAKE_LIBTOOL}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find codesign
                    OUTPUT_VARIABLE CMAKE_CODESIGN_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_CODESIGN ${CMAKE_CODESIGN_val} CACHE FILEPATH "Codesign")
    if (IS_FIRST_RUN)
        message(STATUS "Using codesign ${CMAKE_CODESIGN}")
    endif()
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find codesign_allocate
                    OUTPUT_VARIABLE CMAKE_CODESIGN_ALLOCATE_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_CODESIGN_ALLOCATE ${CMAKE_CODESIGN_ALLOCATE_val} CACHE FILEPATH "Codesign_Allocate")
    if (IS_FIRST_RUN)
        message(STATUS "Using codesign_allocate ${CMAKE_CODESIGN_ALLOCATE}")
    endif()
    if("${PLATFORM_NAME}" STREQUAL "iphonesimulator")
        set(IOS_TOOLCHAIN_FLAGS "-isysroot ${CMAKE_OSX_SYSROOT} -mios-version-min=${MIN_IOS_SDK_TARGET}")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${IOS_TOOLCHAIN_FLAGS}" CACHE STRING "toolchain_cflags" FORCE)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IOS_TOOLCHAIN_FLAGS} -fobjc-arc" CACHE STRING "toolchain_cxxflags" FORCE)
        set(CMAKE_LINK_FLAGS "${CMAKE_LINK_FLAGS} ${IOS_TOOLCHAIN_FLAGS}" CACHE STRING "toolchain_linkflags" FORCE)
    elseif("${PLATFORM_NAME}" STREQUAL "iphoneos")
        set(IOS_TOOLCHAIN_FLAGS "-arch arm64 -target arm-apple-darwin -isysroot ${CMAKE_OSX_SYSROOT} -mios-version-min=${MIN_IOS_SDK_TARGET}")
        set(CMAKE_C_FLAGS "${IOS_TOOLCHAIN_FLAGS}" CACHE STRING "toolchain_cflags" FORCE)
        set(CMAKE_CXX_FLAGS "${IOS_TOOLCHAIN_FLAGS} -fobjc-arc" CACHE STRING "toolchain_cxxflags" FORCE)
        set(CMAKE_LINK_FLAGS "${IOS_TOOLCHAIN_FLAGS}" CACHE STRING "toolchain_linkflags" FORCE)
    endif()
elseif (WASM_TARGET)
    message("Cross-compiling for WebAssembly")
    unset(CMAKE_C_COMPILER)
    unset(CMAKE_CXX_COMPILER)
    unset(CMAKE_AR)
    unset(CMAKE_RANLIB)
    unset(CMAKE_C_COMPILER_AR)
    unset(CMAKE_CXX_COMPILER_AR)
    unset(CMAKE_C_COMPILER_RANLIB)
    unset(CMAKE_CXX_COMPILER_RANLIB)
    file(GLOB cmake_dirs RELATIVE ${QT_SDK_DIR}/lib/cmake ${QT_SDK_DIR}/lib/cmake/*)
    foreach (cmake_dir ${cmake_dirs})
        if(IS_DIRECTORY ${QT_SDK_DIR}/lib/cmake/${cmake_dir})
            set(${cmake_dir}_DIR ${QT_SDK_DIR}/lib/cmake/${cmake_dir})
            if ("${cmake_dir}" STREQUAL "Qt5")
                set(QT_DIR ${QT_SDK_DIR}/lib/cmake/Qt5)
            elseif ("${cmake_dir}" STREQUAL "Qt6")
                set(QT_DIR ${QT_SDK_DIR}/lib/cmake/Qt6)
            endif()
        endif ()
    endforeach ()
    message("Loading ${WASM_SDK}/cmake/Modules/Platform/Emscripten.cmake")
    include(${WASM_SDK}/emscripten/cmake/Modules/Platform/Emscripten.cmake)
    #
    # Setting linker flags
    #
    set(EMCC_COMMON_LFLAGS "-flto -Oz -s WASM_MEM_MAX=256MB -s TOTAL_MEMORY=64MB -lidbfs.js -s WASM=1 -s FULL_ES2=1 -s USE_WEBGL2=1 -lembind")
    set(EMCC_COMMON_LFLAGS_DEBUG "-s ASSERTIONS=2 -s DEMANGLE_SUPPORT=1 -s GL_DEBUG=1")
    set(CMAKE_EXE_LINKER_FLAGS "${EMCC_COMMON_LFLAGS}" CACHE STRING "webassembly_toolchain_linkflags" FORCE)
    set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${EMCC_COMMON_LFLAGS} ${EMCC_COMMON_LFLAGS_DEBUG}" CACHE STRING "webassembly_toolchain_linkflags_debug" FORCE)
endif()
