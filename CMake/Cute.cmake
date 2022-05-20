#
# Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
# All rights reserved
#

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

if (NOT DEFINED QT_SDK_DIR)
    message(FATAL_ERROR "QT_SDK_DIR must be defined as the directory containing the Qt installation.")
endif()
if (NOT DEFINED ENV{HAS_ALREADY_CONFIGURED_TARGET_ENV_VAR})
    set(IS_FIRST_RUN True)
    set(ENV{HAS_ALREADY_CONFIGURED_TARGET_ENV_VAR} "True")
else()
    set(IS_FIRST_RUN False)
endif()
#
# Setting global compiler options
#
if (CMAKE_CXX_COMPILER_ID MATCHES Clang OR CMAKE_CXX_COMPILER_ID MATCHES GNU)
    if (WASM_TARGET)
        set(CMAKE_C_FLAGS "${CFLAGS} ${CMAKE_C_FLAGS} -fvisibility=hidden -fstack-check")
        set(CMAKE_CXX_FLAGS "${CXXFLAGS} ${CMAKE_CXX_FLAGS} -fvisibility=hidden -fvisibility-inlines-hidden -fstack-check")
    else()
        set(CMAKE_C_FLAGS "${CFLAGS} ${CMAKE_C_FLAGS} -fvisibility=hidden -fstack-protector-strong -fstack-check")
        set(CMAKE_CXX_FLAGS "${CXXFLAGS} ${CMAKE_CXX_FLAGS} -fno-rtti -fvisibility=hidden -fvisibility-inlines-hidden -fstack-protector-strong -fstack-check")
    endif()
    if (NOT CMAKE_CXX_COMPILER_ID MATCHES Clang)
        add_link_options(LINKER:-z,noexecstack,-z,relro,-z,now)
    endif ()
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(-fno-omit-frame-pointer)
    else()
        add_compile_options(-O3)
        add_link_options(-O3)
        add_compile_options(-fomit-frame-pointer)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION True)
        if (ANDROID_TARGET)
            # The command below is required: see https://gitlab.kitware.com/cmake/cmake/-/issues/21772
            STRING(REGEX REPLACE "-fuse-ld=gold" "" CMAKE_CXX_LINK_OPTIONS_IPO ${CMAKE_CXX_LINK_OPTIONS_IPO})
        endif()
    endif()
endif()
if (CMAKE_VERSION VERSION_LESS 3.14)
    if (UNIX)
        add_link_options(-pie)
    endif ()
else ()
    cmake_policy(SET CMP0083 NEW)
    set (CMAKE_POSITION_INDEPENDENT_CODE True)
endif ()

if (ANDROID_TARGET)
    unset(ANDROID_PLATFORM)
    set(QT_SDK_DIR ${ANDROID_SDK_DIR_${ANDROID_ABI}})
endif()
set(CMAKE_PREFIX_PATH ${QT_SDK_DIR}/lib/cmake;${QT_SDK_DIR};${CMAKE_PREFIX_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ON)
list(APPEND CMAKE_FIND_ROOT_PATH "${QT_SDK_DIR}")
find_package(QT NAMES Qt6 Qt5 COMPONENTS Core REQUIRED)
if (${QT_FOUND})
    get_filename_component(QT_INSTALL_DIR "${QT_DIR}/../../.." ABSOLUTE)
    if (IS_FIRST_RUN)
        message(STATUS "Found Qt ${QT_VERSION} at ${QT_INSTALL_DIR}.")
    endif()
endif ()

#
# Configure Apple macOS build
#
if (APPLE AND NOT DEFINED PLATFORM_NAME)
    if (IS_FIRST_RUN)
        message("Targeting macOS")
    endif()
    set(PLATFORM_NAME macosx)
    set(APPLE_MACOSX True)
    #
    # Configuring macOS toolchain
    #
    if (IS_FIRST_RUN)
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
    # Setting C Compiler
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find clang
                    OUTPUT_VARIABLE CMAKE_C_COMPILER
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (IS_FIRST_RUN)
        message(STATUS "Using C compiler ${CMAKE_C_COMPILER}")
    endif()
    #Setting C++ Compiler
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find clang++
                    OUTPUT_VARIABLE CMAKE_CXX_COMPILER
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (IS_FIRST_RUN)
        message(STATUS "Using C++ compiler ${CMAKE_CXX_COMPILER}")
    endif()
    set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER})
    if (IS_FIRST_RUN)
        message(STATUS "Using linker ${CMAKE_CXX_COMPILER}")
    endif()
    # Setting ar
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find ar
                    OUTPUT_VARIABLE CMAKE_AR_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_AR ${CMAKE_AR_val} CACHE FILEPATH "Archiver")
    if (IS_FIRST_RUN)
        message(STATUS "Using ar ${CMAKE_AR}")
    endif()
    # Setting runlib
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find ranlib
                    OUTPUT_VARIABLE CMAKE_RANLIB_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_RANLIB ${CMAKE_RANLIB_val} CACHE FILEPATH "Ranlib")
    if (IS_FIRST_RUN)
        message(STATUS "Using ranlib ${CMAKE_RANLIB}")
    endif()
    # Setting strip
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find strip
                    OUTPUT_VARIABLE CMAKE_STRIP_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_STRIP ${CMAKE_STRIP_val} CACHE FILEPATH "Strip")
    if (IS_FIRST_RUN)
        message(STATUS "Using strip ${CMAKE_STRIP}")
    endif()
    # Setting dsymutil
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find dsymutil
                    OUTPUT_VARIABLE CMAKE_DSYMUTIL_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_DSYMUTIL ${CMAKE_DSYMUTIL_val} CACHE FILEPATH "Dsymutil")
    if (IS_FIRST_RUN)
        message(STATUS "Using dsymutil ${CMAKE_DSYMUTIL}")
    endif()
    # Setting objdump
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find objdump
                    OUTPUT_VARIABLE CMAKE_OBJDUMP_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_OBJDUMP ${CMAKE_OBJDUMP_val} CACHE FILEPATH "ObjDump")
    if (IS_FIRST_RUN)
        message(STATUS "Using objdump ${CMAKE_OBJDUMP}")
    endif()
    # Set libtool
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find libtool
                    OUTPUT_VARIABLE CMAKE_LIBTOOL_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_LIBTOOL ${CMAKE_LIBTOOL_val} CACHE FILEPATH "Libtool")
    if (IS_FIRST_RUN)
        message(STATUS "Using libtool ${CMAKE_LIBTOOL}")
    endif()
    # Setting codesign
    execute_process(COMMAND xcrun -sdk ${SDKROOT} -find codesign
                    OUTPUT_VARIABLE CMAKE_CODESIGN_val
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_CODESIGN ${CMAKE_CODESIGN_val} CACHE FILEPATH "Codesign")
    if (IS_FIRST_RUN)
        message(STATUS "Using codesign ${CMAKE_CODESIGN}")
    endif()
    # Setting codesign_allocate
    execute_process(
            COMMAND xcrun -sdk ${SDKROOT} -find codesign_allocate
            OUTPUT_VARIABLE CMAKE_CODESIGN_ALLOCATE_val
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    set(CMAKE_CODESIGN_ALLOCATE ${CMAKE_CODESIGN_ALLOCATE_val} CACHE
        FILEPATH "Codesign_Allocate")
    if (IS_FIRST_RUN)
        message(STATUS "Using codesign_allocate ${CMAKE_CODESIGN_ALLOCATE}")
    endif()
endif()

if (WASM_TARGET)
    if (IS_FIRST_RUN)
        message("Cross-building for Webassembly")
    endif()
    function (cute_add_executable TARGET_NAME)
        if (NOT "${ARGC}" EQUAL "1")
            message(FATAL_ERROR "Only the target name can be passed to cute_add_executable. Add sources through target_sources command.")
        endif()
        add_executable(${TARGET_NAME} ${ARGN})
        target_compile_definitions(${TARGET_NAME} PRIVATE WASM)
        add_custom_command(TARGET
                           ${TARGET_NAME}
                           POST_BUILD
                           COMMAND
                           ${CMAKE_COMMAND} -E copy ${QT_SDK_DIR}/plugins/platforms/qtloader.js ${CMAKE_CURRENT_BINARY_DIR}
                           COMMAND
                           ${CMAKE_COMMAND} -E copy ${QT_SDK_DIR}/plugins/platforms/qtlogo.svg ${CMAKE_CURRENT_BINARY_DIR}
                           COMMENT
                           "Added qtloader.js and qtlogo.svg to project")
        set(APPNAME ${TARGET_NAME})
        configure_file(${QT_SDK_DIR}/plugins/platforms/wasm_shell.html ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}.html @ONLY)
        if (${QT_VERSION_MAJOR} EQUAL 5)
            target_sources(${TARGET_NAME}
                           PRIVATE
                           ${QT_IMPORT_PLUGINS_CPP_FILE}
                           ${QT_QML_IMPORT_PLUGINS_CPP_FILE})
            foreach(plugin ${CORE_PLUGINS_LIBS_LIST})
                target_link_libraries(${TARGET_NAME} PRIVATE ${plugin})
            endforeach()
            foreach(plugin ${QML_PLUGINS_LIBS_LIST})
                target_link_libraries(${TARGET_NAME} PRIVATE ${plugin})
            endforeach()
            foreach(qt_lib ${CUTE_QT_LIBS_LIST})
                target_link_libraries(${TARGET_NAME} PRIVATE ${qt_lib})
            endforeach()
        endif()
    endfunction ()

    function (cute_add_library TARGET_NAME LIBRARY_TYPE)
        if (NOT "${ARGC}" EQUAL "2")
            message(FATAL_ERROR "Only the target name and the library type can be passed to cute_add_library. Add sources through target_sources command.")
        endif()
        if (NOT (${LIBRARY_TYPE} STREQUAL "STATIC"
            OR ${LIBRARY_TYPE} STREQUAL "OBJECT"))
            message(FATAL_ERROR "When specifying a library with cute_add_library the second argument must be the library type having a value of either STATIC, or OBJECT when targeting WebAssembly.")
        endif()
        add_library(${TARGET_NAME} ${LIBRARY_TYPE} ${TARGET_ARGN})
        target_compile_definitions(${TARGET_NAME} PRIVATE WASM)
    endfunction ()
elseif (APPLE_MACOSX OR APPLE_IOS_TARGET)
    if (${PLATFORM_NAME} STREQUAL macosx
        OR ${PLATFORM_NAME} STREQUAL iphoneos
        OR ${PLATFORM_NAME} STREQUAL iphonesimulator)
        function (cute_add_executable TARGET_NAME)
            if (NOT "${ARGC}" EQUAL "1")
                message(FATAL_ERROR "Only the target name can be passed to cute_add_executable. Add sources through the target_sources command.")
            endif()
            if (MACOSX_BUNDLE)
                add_executable(${TARGET_NAME} MACOSX_BUNDLE ${ARGN})
                set_target_properties(${TARGET_NAME} PROPERTIES BUNDLE True)
                if(${PLATFORM_NAME} STREQUAL iphoneos OR ${PLATFORM_NAME} STREQUAL iphonesimulator)
                    if ((${QT_VERSION_MAJOR} EQUAL 6) AND (NOT QT_HOST_PATH))
                        message(FATAL_ERROR "Qt6 requires QT_HOST_PATH to be defined when targeting Android or iOS. Note that QT_HOST_PATH must point to the host (Linux, Windows or macOS) installation folder.")
                    endif ()
                    target_link_options(${TARGET_NAME} PRIVATE "-Wl,-e,_qt_main_wrapper")
                    if (${QT_VERSION_MAJOR} EQUAL 5)
                        target_sources(${TARGET_NAME}
                                       PRIVATE
                                       ${QT_IMPORT_PLUGINS_CPP_FILE}
                                       ${QT_QML_IMPORT_PLUGINS_CPP_FILE})
                        foreach(plugin ${CORE_PLUGINS_LIBS_LIST})
                            target_link_libraries(${TARGET_NAME} PRIVATE ${plugin})
                        endforeach()
                        foreach(plugin ${QML_PLUGINS_LIBS_LIST})
                            target_link_libraries(${TARGET_NAME} PRIVATE ${plugin})
                        endforeach()
                        foreach(qt_lib ${CUTE_QT_LIBS_LIST})
                            target_link_libraries(${TARGET_NAME} PRIVATE ${qt_lib})
                        endforeach()
                    endif ()
                    target_link_libraries(${TARGET_NAME} PRIVATE "-framework AVFAudio -framework AVFoundation -framework WebKit -framework CoreMedia -framework CoreMotion -framework CoreVideo -framework GameController -framework CoreLocation -framework OpenAL -framework CoreBluetooth")
                    if ("${MACOSX_BUNDLE_INFO_PLIST}" STREQUAL "")
                        message("Using ${DEFAULT_IOS_PLIST_FILE} as template plist file for iOS.")
                        set(MACOSX_BUNDLE_INFO_PLIST "${DEFAULT_IOS_PLIST_FILE}")
                    endif()
                    #
                    # Splash screen on iOS is set using a storyboard, instead of a bunch of launch images.
                    # If the user has set a custom splash screen we will use it. Otherwise a default
                    # splash screen with white background will be used instead. After setting the splash
                    # screen to use, we have to compile it using the ibtool.
                    #
                    if ("${SPLASH_SCREEN}" STREQUAL "")
                        set(SPLASH_SCREEN "${DEFAULT_SPLASH_SCREEN}")
                    endif()
                    get_filename_component(SPLASH_SCREEN_BASE_NAME "${SPLASH_SCREEN}" NAME_WLE)
                    set(SPLASH_SCREEN_BASE_NAME "${SPLASH_SCREEN_BASE_NAME}" PARENT_SCOPE)
                    set(COMPILED_SPLASH_SCREEN "${CMAKE_CURRENT_BINARY_DIR}/generated/${SPLASH_SCREEN_BASE_NAME}.storyboardc")
                    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/generated"
                                    COMMAND ibtool --compile ${COMPILED_SPLASH_SCREEN} "${SPLASH_SCREEN}"
                                    OUTPUT_QUIET
                                    ERROR_QUIET)
                    if (NOT EXISTS "${COMPILED_SPLASH_SCREEN}")
                        message(FATAL_ERROR "Failed to compile splash screen storyboard file ${SPLASH_SCREEN}.")
                    else()
                        message("Generated compiled splash screen storyboard file ${COMPILED_SPLASH_SCREEN} from ${SPLASH_SCREEN}")
                        set_target_properties(${TARGET_NAME} PROPERTIES
                                              SPLASH_SCREEN_BASE_NAME "${SPLASH_SCREEN_BASE_NAME}")
                    endif()
                    add_custom_command(TARGET
                                       ${TARGET_NAME}
                                       POST_BUILD
                                       COMMAND
                                       ${CMAKE_COMMAND} -E make_directory "$<TARGET_BUNDLE_DIR:${TARGET_NAME}>/${SPLASH_SCREEN_BASE_NAME}.storyboardc"
                                       COMMAND
                                       ${CMAKE_COMMAND} -E copy_directory "${COMPILED_SPLASH_SCREEN}" $<TARGET_BUNDLE_DIR:${TARGET_NAME}>/${SPLASH_SCREEN_BASE_NAME}.storyboardc
                                       COMMENT
                                       "Copying compiled splash screen storyboard file ${COMPILED_SPLASH_SCREEN} to iOS app bundle")
                endif()
                if (MACOSX_BUNDLE_BUNDLE_NAME)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_BUNDLE_NAME ${MACOSX_BUNDLE_BUNDLE_NAME})
                else()
                    set(MACOSX_BUNDLE_BUNDLE_NAME ${TARGET_NAME})
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_BUNDLE_NAME ${MACOSX_BUNDLE_BUNDLE_NAME})
                endif()
                if (MACOSX_BUNDLE_BUNDLE_VERSION)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_BUNDLE_VERSION ${MACOSX_BUNDLE_BUNDLE_VERSION})
                endif()
                if (MACOSX_BUNDLE_COPYRIGHT)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_COPYRIGHT ${MACOSX_BUNDLE_COPYRIGHT})
                endif()
                if (MACOSX_BUNDLE_GUI_IDENTIFIER)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOSX_BUNDLE_GUI_IDENTIFIER})
                endif()
                if (MACOSX_BUNDLE_ICON_FILE)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_ICON_FILE ${MACOSX_BUNDLE_ICON_FILE})
                endif()
                if (MACOSX_BUNDLE_INFO_STRING)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_INFO_STRING ${MACOSX_BUNDLE_INFO_STRING})
                endif()
                if (MACOSX_BUNDLE_LONG_VERSION_STRING)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_LONG_VERSION_STRING ${MACOSX_BUNDLE_LONG_VERSION_STRING})
                endif()
                if (MACOSX_BUNDLE_SHORT_VERSION_STRING)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_SHORT_VERSION_STRING ${MACOSX_BUNDLE_SHORT_VERSION_STRING})
                endif()
                if (MACOSX_BUNDLE_INFO_PLIST)
                    set_target_properties(${TARGET_NAME} PROPERTIES
                                          MACOSX_BUNDLE_INFO_PLIST ${MACOSX_BUNDLE_INFO_PLIST})
                endif()
            else()
                add_executable(${TARGET_NAME} ${ARGN})
            endif()
            target_compile_definitions(${TARGET_NAME} PRIVATE APPLE)
            if (APPLE_MACOSX)
                target_compile_definitions(${TARGET_NAME} PRIVATE APPLE_MACOSX)
            elseif (APPLE_IOS_DEVICE OR APPLE_IOS_SIMULATOR)
                target_compile_definitions(${TARGET_NAME} PRIVATE APPLE_IOS)
            endif()
            if (MACOSX_BUNDLE)
                if (APPLE_IOS_DEVICE OR APPLE_IOS_SIMULATOR)
                    if (DEFINED APPLE_CODE_SIGN_IDENTITY)
                        add_custom_command(TARGET
                                           ${TARGET_NAME}
                                           POST_BUILD
                                           COMMAND
                                           codesign --force -s ${APPLE_CODE_SIGN_IDENTITY} $<TARGET_BUNDLE_DIR:${TARGET_NAME}>
                                           COMMENT
                                           "Signing ${MACOSX_BUNDLE_BUNDLE_NAME}.app")
                    endif()
                else()
                    if (DEFINED APPLE_CODE_SIGN_IDENTITY)
                        set(APPLE_CODESIGN_CMD_OPT "-codesign=${APPLE_CODE_SIGN_IDENTITY}")
                    else()
                        set(APPLE_CODESIGN_CMD_OPT "")
                    endif()
                    #
                    # Adding Qt dependencies to app bundle by running Qt's macdeployqt
                    #
                    add_custom_command(TARGET
                                       ${TARGET_NAME}
                                       POST_BUILD
                                       COMMAND
                                       ${CMAKE_COMMAND} -E echo "Adding Qt dependencies to macOS app ${MACOSX_BUNDLE_BUNDLE_NAME}.app by running macdeployqt"
                                       COMMAND
                                       ${QT_SDK_DIR}/bin/macdeployqt $<TARGET_BUNDLE_DIR:${TARGET_NAME}> -qmldir=${CMAKE_CURRENT_SOURCE_DIR} ${APPLE_CODESIGN_CMD_OPT} -appstore-compliant)
                endif()
            endif()
        endfunction ()

        function (cute_add_library TARGET_NAME LIBRARY_TYPE)
            if (NOT "${ARGC}" EQUAL "2")
                message(FATAL_ERROR "Only the target name and the library type can be passed to cute_add_library. Add sources through target_sources command.")
            endif()
            if (NOT (${LIBRARY_TYPE} STREQUAL "STATIC"
                OR ${LIBRARY_TYPE} STREQUAL "SHARED"))
                message(FATAL_ERROR "When specifying a library with cute_add_library the second argument must be the library type having a value of either STATIC or SHARED.")
            endif()
            add_library(${TARGET_NAME} ${LIBRARY_TYPE} ${TARGET_ARGN})
            target_compile_definitions(${TARGET_NAME} PRIVATE APPLE)
            if (APPLE_MACOSX)
                target_compile_definitions(${TARGET_NAME} PRIVATE APPLE_MACOSX)
            elseif (APPLE_IOS_DEVICE OR APPLE_IOS_SIMULATOR)
                target_compile_definitions(${TARGET_NAME} PRIVATE APPLE_IOS)
            endif()
            if (FRAMEWORK)
                set_target_properties(${TARGET_NAME} PROPERTIES FRAMEWORK True)
                if(MACOSX_FRAMEWORK_BUNDLE_VERSION)
                    set_target_properties(${TARGET_NAME} PROPERTIES MACOSX_FRAMEWORK_BUNDLE_VERSION ${MACOSX_FRAMEWORK_BUNDLE_VERSION})
                endif()
                if(MACOSX_FRAMEWORK_ICON_FILE)
                    set_target_properties(${TARGET_NAME} PROPERTIES MACOSX_FRAMEWORK_ICON_FILE ${MACOSX_FRAMEWORK_ICON_FILE})
                endif()
                if(MACOSX_FRAMEWORK_IDENTIFIER)
                    set_target_properties(${TARGET_NAME} PROPERTIES MACOSX_FRAMEWORK_IDENTIFIER ${MACOSX_FRAMEWORK_IDENTIFIER})
                endif()
                if(MACOSX_FRAMEWORK_SHORT_VERSION_STRING)
                    set_target_properties(${TARGET_NAME} PROPERTIES MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${MACOSX_FRAMEWORK_SHORT_VERSION_STRING})
                endif()
                if (DEFINED APPLE_CODE_SIGN_IDENTITY)
                    add_custom_command(TARGET
                                       ${TARGET_NAME}
                                       POST_BUILD
                                       COMMAND
                                       codesign --force -s ${APPLE_CODE_SIGN_IDENTITY} $<TARGET_BUNDLE_DIR:${TARGET_NAME}>
                                       COMMENT
                                       "Signing ${TARGET_NAME}.framework")
                endif()
            endif()
        endfunction ()
    else()
        message(FATAL_ERROR "On Apple, PLATFORM_NAME must be either macosx, iphoneos or iphonesimulator")
    endif()
elseif (ANDROID_TARGET)
    if ((${QT_VERSION_MAJOR} EQUAL 6) AND (NOT QT_HOST_PATH))
        message(FATAL_ERROR "Qt6 requires QT_HOST_PATH to be defined when targeting Android or iOS. Note that QT_HOST_PATH must point to the host (Linux, Windows or macOS) installation folder.")
    endif ()
    if (IS_FIRST_RUN)
        message("Building for Android")
    endif()
    function (cute_add_executable TARGET_NAME)
        if (NOT "${ARGC}" EQUAL "1")
            message(FATAL_ERROR "Only the target name can be passed to cute_add_executable. Add sources through target_sources command.")
        endif()
        if (NOT AndroidMultiAbiBuild)
            message("Cross-compiling for Android with multi-abi support. Building ${TARGET_NAME} for the following abis: ${ANDROID_ABIS}.")
            set(ANDROID_SYSROOT_armeabi-v7a arm-linux-androideabi)
            set(ANDROID_SYSROOT_arm64-v8a aarch64-linux-android)
            set(ANDROID_SYSROOT_x86 i686-linux-android)
            set(ANDROID_SYSROOT_x86_64 x86_64-linux-android)
            set(QT_ANDROID_APPLICATION_BINARY ${TARGET_NAME})
            unset(QT_ANDROID_ARCHITECTURES)
            foreach(abi ${ANDROID_ABIS})
                if (ANDROID_SYSROOT_${abi})
                    list(APPEND QT_ANDROID_ARCHITECTURES "\"${abi}\" : \"${ANDROID_SYSROOT_${abi}}\"")
                endif()
            endforeach()
            string(REPLACE ";" ",\n" QT_ANDROID_ARCHITECTURES "${QT_ANDROID_ARCHITECTURES}")

            macro(generate_json_variable_list var_list json_key)
                if (${var_list})
                    set(QT_${var_list} "\"${json_key}\": \"")
                    string(REPLACE ";" "," joined_var_list "${${var_list}}")
                    string(APPEND QT_${var_list} "${joined_var_list}\",")
                endif()
            endmacro()

            macro(generate_json_variable var json_key)
                if (${var})
                    set(QT_${var} "\"${json_key}\": \"${${var}}\",")
                endif()
            endmacro()

            generate_json_variable_list(ANDROID_DEPLOYMENT_DEPENDENCIES "deployment-dependencies")
            generate_json_variable_list(ANDROID_EXTRA_PLUGINS "android-extra-plugins")
            generate_json_variable(ANDROID_PACKAGE_SOURCE_DIR "android-package-source-directory")
            generate_json_variable(ANDROID_VERSION_CODE "android-version-code")
            generate_json_variable(ANDROID_VERSION_NAME "android-version-name")
            generate_json_variable_list(ANDROID_EXTRA_LIBS "android-extra-libs")
            generate_json_variable_list(QML_IMPORT_PATH "qml-import-paths")
            generate_json_variable_list(ANDROID_MIN_SDK_VERSION "android-min-sdk-version")
            generate_json_variable_list(ANDROID_TARGET_SDK_VERSION "android-target-sdk-version")
            if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)
                set(ANDROID_HOST_TAG linux-x86_64)
            elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin)
                set(ANDROID_HOST_TAG darwin-x86_64)
            elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows)
                set(ANDROID_HOST_TAG windows-x86_64)
            endif()
            set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK}/toolchains/llvm/prebuilt/${ANDROID_HOST_TAG}")
            unset(QT_EXTRA_PREFIX_DIRS)
            if(DEFINED ANDROID_SDK_DIR_armeabi-v7a)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_armeabi-v7a}/src)
                list(APPEND QT_EXTRA_PREFIX_DIRS "\"${ANDROID_SDK_DIR_armeabi-v7a}\"")
            endif()
            if(DEFINED ANDROID_SDK_DIR_arm64-v8a)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_arm64-v8a}/src)
                list(APPEND QT_EXTRA_PREFIX_DIRS "\"${ANDROID_SDK_DIR_arm64-v8a}\"")
            endif()
            if(DEFINED ANDROID_SDK_DIR_x86)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_x86}/src)
                list(APPEND QT_EXTRA_PREFIX_DIRS "\"${ANDROID_SDK_DIR_x86}\"")
            endif()
            if(DEFINED ANDROID_SDK_DIR_x86_64)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_x86_64}/src)
                list(APPEND QT_EXTRA_PREFIX_DIRS "\"${ANDROID_SDK_DIR_x86_64}\"")
            endif()
            string(REPLACE ";" ",\n" QT_EXTRA_PREFIX_DIRS "${QT_EXTRA_PREFIX_DIRS}")
            if (NOT ANDROID_SOURCE_DIR)
                message(FATAL_ERROR "Failed to set android package source directory.")
            endif()
            if (${QT_VERSION_MAJOR} EQUAL 6)
                set(QML_IMPORT_SCANNER_FILE_PATH ${QT_HOST_PATH}/libexec/qmlimportscanner)
                generate_json_variable_list(QML_IMPORT_SCANNER_FILE_PATH "qml-importscanner-binary")
                set(RCC_FILE_PATH ${QT_HOST_PATH}/libexec/rcc)
                generate_json_variable_list(RCC_FILE_PATH "rcc-binary")
            endif()

            if (NOT DEFINED ANDROID_BUILD_TOOLS_REVISION)
                file(GLOB build_tool_dirs LIST_DIRECTORIES true RELATIVE ${ANDROID_SDK}/build-tools/ ${ANDROID_SDK}/build-tools/*)
                set(BUILD_TOOL_MAJOR "0")
                set(BUILD_TOOL_MINOR "0")
                set(BUILD_TOOL_PATCH "0")

                foreach(dir ${build_tool_dirs})
                    string(REPLACE "." ";" VERSION_LIST ${dir})
                    list(GET VERSION_LIST 0 VERSION_MAJOR)
                    list(GET VERSION_LIST 1 VERSION_MINOR)
                    list(GET VERSION_LIST 2 VERSION_PATCH)
                    if ("${BUILD_TOOL_MAJOR}" LESS "${VERSION_MAJOR}")
                        set(BUILD_TOOL_MAJOR "${VERSION_MAJOR}")
                        set(BUILD_TOOL_MINOR "${VERSION_MINOR}")
                        set(BUILD_TOOL_PATCH "${VERSION_PATCH}")
                    endif()
                endforeach()
                if ("${BUILD_TOOL_MAJOR}" EQUAL "0")
                    message(FATAL_ERROR "Failed to fetch Android SDK build tool")
                endif()
                set(ANDROID_BUILD_TOOLS_REVISION "${BUILD_TOOL_MAJOR}.${BUILD_TOOL_MINOR}.${BUILD_TOOL_PATCH}")
            endif()
            message("Using Android SDK build tool version ${ANDROID_BUILD_TOOLS_REVISION}")
            generate_json_variable(ANDROID_BUILD_TOOLS_REVISION "sdkBuildToolsRevision")
            if (${QT_VERSION_MAJOR} EQUAL 5)
                get_filename_component(QT_INSTALL_DIR "${ANDROID_SOURCE_DIR}/.." ABSOLUTE)
                set(QT_INSTALL_DIR \"${QT_INSTALL_DIR}\")
            elseif(${QT_VERSION_MAJOR} EQUAL 6)
                if (${QT_VERSION_MINOR} LESS 3)
                    message(FATAL_ERROR "Qt 6.3 is the minimum supported Qt6 version when targeting Android.")
                else()
                    set(QT_EXTRA_PREFIX_DIRS "")
                    unset(QT_INSTALL_DIR)
                    foreach(abi ${ANDROID_ABIS})
                        if (ANDROID_SDK_DIR_${abi})
                            list(APPEND QT_INSTALL_DIR "\"${abi}\" : \"${ANDROID_SDK_DIR_${abi}}\"")
                        endif()
                    endforeach()
                    string(REPLACE ";" ",\n" QT_INSTALL_DIR "${QT_INSTALL_DIR}")
                    set(QT_INSTALL_DIR {${QT_INSTALL_DIR}})
                endif()
            else()
                message(FATAL_ERROR "Unsupported Qt version.")
            endif()

            configure_file("${ANDROID_DEPLOYMENT_SETTINGS_FILE}"
                           "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android_deployment_settings.json" @ONLY)

            include(ExternalProject)

            file(TO_CMAKE_PATH "${CMAKE_TOOLCHAIN_FILE}" toolchain_file)

            # We need to call androiddeployqt below. On Qt6 we have to use QT_HOST_PATH.
            # For Qt5, androiddeployqt is located on android abi folder at bin directory.
            if (${QT_VERSION_MAJOR} EQUAL 5)
                set(ANDROID_DEPLOY_QT "${QT_SDK_DIR}/bin/androiddeployqt")
            else()
                if (NOT QT_HOST_PATH)
                    message(FATAL_ERROR "Failed to find androiddeployqt. QT_HOST_PATH must be defined.")
                endif()
                set(ANDROID_DEPLOY_QT "${QT_HOST_PATH}/${QT6_HOST_INFO_BINDIR}/androiddeployqt")
            endif()
            message("Using androiddeployqt from ${ANDROID_DEPLOY_QT}")
            string(TOLOWER ${CMAKE_BUILD_TYPE} build_type_lower)
            if ("${build_type_lower}" STREQUAL "debug")
                set(ANDROID_DEPLOY_QT_CMD_ARGS "")
                set(APP_BUNDLE_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android-build/build/outputs/bundle/debug/android-build-debug.aab)
            else()
                set(ANDROID_DEPLOY_QT_CMD_ARGS "--release")
                set(APP_BUNDLE_FILE_PATH ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android-build/build/outputs/bundle/release/android-build-release.aab)
            endif()
            set(BUNDLE_TOOL_SIGN_CMD_OPTS "")
            if (DEFINED KS_URL AND NOT DEFINED KS_KEY_ALIAS)
                message(FATAL_ERROR "Key alias must be set when specifying a keystore.")
            endif()
            if (DEFINED KS_URL AND NOT DEFINED KS_PASS_FILE)
                message(FATAL_ERROR "Keystore password file is not optional when specifying a keystore.")
            endif()
            if ((DEFINED KS_PASS_FILE OR DEFINED KS_KEY_PASS_FILE OR DEFINED KS_KEY_ALIAS) AND NOT DEFINED KS_URL)
                message(FATAL_ERROR "Keystore url must be set when setting key alias, keystore password file or keystore key password file.")
            endif()
            if (DEFINED KS_URL)
                set(BUNDLE_TOOL_SIGN_CMD_OPTS ${BUNDLE_TOOL_SIGN_CMD_OPTS} --ks=\"${KS_URL}\")
                if (DEFINED KS_KEY_ALIAS)
                    set(ANDROID_DEPLOY_QT_CMD_ARGS "${ANDROID_DEPLOY_QT_CMD_ARGS} --sign \"${KS_URL}\" \"${KS_KEY_ALIAS}\"")
                    set(BUNDLE_TOOL_SIGN_CMD_OPTS ${BUNDLE_TOOL_SIGN_CMD_OPTS} --ks-key-alias=\"${KS_KEY_ALIAS}\")
                else()
                    message(FATAL_ERROR "Keystore specification requires a key alias to be specified.")
                endif()
                if (DEFINED KS_PASS_FILE)
                    if (NOT EXISTS ${KS_PASS_FILE})
                        message(FATAL_ERROR "Keystore password file ${KS_PASS_FILE} does not exist.")
                    endif()
                    file(READ ${KS_PASS_FILE} KS_PASS)
                    set(ANDROID_DEPLOY_QT_CMD_ARGS "${ANDROID_DEPLOY_QT_CMD_ARGS} --storepass \"${KS_PASS}\"")
                    set(BUNDLE_TOOL_SIGN_CMD_OPTS ${BUNDLE_TOOL_SIGN_CMD_OPTS} --ks-pass=file:\"${KS_PASS_FILE}\")
                    if (DEFINED KS_KEY_PASS_FILE)
                        if (NOT EXISTS ${KS_KEY_PASS_FILE})
                            message(FATAL_ERROR "Keystore key password file ${KS_KEY_PASS_FILE} does not exist.")
                        endif()
                        file(READ ${KS_KEY_PASS_FILE} KS_KEY_PASS)
                        set(ANDROID_DEPLOY_QT_CMD_ARGS "${ANDROID_DEPLOY_QT_CMD_ARGS} --keypass \"${KS_KEY_PASS}\"")
                        set(BUNDLE_TOOL_SIGN_CMD_OPTS ${BUNDLE_TOOL_SIGN_CMD_OPTS} --key-pass=file:\"${KS_KEY_PASS_FILE}\")
                    endif()
                    message("Using keystore ${KS_URL} to sign bundle/apk.")
                endif()
            endif()
            set(APP_BUNDLE_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/${TARGET_NAME}.aab)
            set(ZIPPED_UNIVERSAL_APK_FILEPATH ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/${TARGET_NAME}.apks)
            set(UNIVERSAL_APK_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME})
            set(UNIVERSAL_APK_FILEPATH ${UNIVERSAL_APK_DIRECTORY}/${TARGET_NAME}.apk)
            add_custom_target(${TARGET_NAME}-all
                              ${CMAKE_COMMAND} -E echo "")
            add_library(${TARGET_NAME} SHARED ${TARGET_ARGN})
            add_dependencies(${TARGET_NAME}-all ${TARGET_NAME})
            set(APP_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android-build/libs/${ANDROID_ABI}")
            set_target_properties(${TARGET_NAME} PROPERTIES APP_BINARY_DIR ${APP_BINARY_DIR})
            set(ANDROID_MACRO_armeabi-v7a ANDROID_ARMEABI_V7A)
            set(ANDROID_MACRO_arm64-v8a ANDROID_ARM64_V8A)
            set(ANDROID_MACRO_x86 ANDROID_X86)
            set(ANDROID_MACRO_x86_64 ANDROID_X86_64)
            target_compile_definitions(${TARGET_NAME} PRIVATE ANDROID)
            target_compile_definitions(${TARGET_NAME} PRIVATE ${ANDROID_MACRO_${ANDROID_ABI}})
            add_custom_command(TARGET
                               ${TARGET_NAME}
                               POST_BUILD
                               COMMAND
                               ${CMAKE_COMMAND} -E make_directory ${APP_BINARY_DIR}
                               COMMAND
                               ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${TARGET_NAME}> ${APP_BINARY_DIR})
            list(GET ANDROID_ABIS 0 FIRST_ANDROID_ABI)
            foreach(CURRENT_ANDROID_ABI ${ANDROID_ABIS})
                if (${CURRENT_ANDROID_ABI} STREQUAL ${FIRST_ANDROID_ABI})
                    continue()
                endif()
                message("Creating project to build ${TARGET_NAME} for ${CURRENT_ANDROID_ABI}")
                ExternalProject_Add(${TARGET_NAME}_${CURRENT_ANDROID_ABI}
                                    SOURCE_DIR "${CMAKE_SOURCE_DIR}"
                                    PREFIX ${TARGET_NAME}-MultiAbi
                                    BUILD_ALWAYS YES
                                    DOWNLOAD_COMMAND ""
                                    INSTALL_COMMAND ""
                                    UPDATE_COMMAND ""
                                    PATCH_COMMAND ""
                                    BUILD_COMMAND ${CMAKE_COMMAND} --build . --target ${TARGET_NAME}
                                    CMAKE_ARGS
                                    -D CMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
                                        -D CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
                                        -D ANDROID_ABI=${CURRENT_ANDROID_ABI}
                                        -D ANDROID_CPP_FEATURES=${ANDROID_CPP_FEATURES}
                                        -D ANDROID_TARGET=True
                                        -D ANDROID_SDK=${ANDROID_SDK}
                                        -D ANDROID_NDK=${ANDROID_NDK}
                                        -D ANDROID_ABIS=${ANDROID_ABIS}
                                        -D QT_SDK_DIR=${ANDROID_SDK_DIR_${CURRENT_ANDROID_ABI}}
                                        -D QT_HOST_PATH=${QT_HOST_PATH}
                                        -D CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
                                        -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                                        -D ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}
                                        -D TARGET_ARGN=${ARGN}
                                        -D APP_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android-build/libs/${CURRENT_ANDROID_ABI}
                                        -D AndroidMultiAbiBuild=True)
                add_dependencies(${TARGET_NAME}-all ${TARGET_NAME}_${CURRENT_ANDROID_ABI})
            endforeach()
            if(DEFINED ANDROID_SDK_DIR_armeabi-v7a)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_armeabi-v7a}/src)
            elseif(DEFINED ANDROID_SDK_DIR_arm64-v8a)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_arm64-v8a}/src)
            elseif(DEFINED ANDROID_SDK_DIR_x86)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_x86}/src)
            elseif(DEFINED ANDROID_SDK_DIR_x86_64)
                set(ANDROID_SOURCE_DIR ${ANDROID_SDK_DIR_x86_64}/src)
            endif()
            if (NOT ANDROID_SOURCE_DIR)
                message(FATAL_ERROR "Failed to set android source directory.")
            endif()
            add_custom_command(TARGET
                               ${TARGET_NAME}-all
                               POST_BUILD
                               COMMAND
                               ${CMAKE_COMMAND} -E copy_directory ${ANDROID_SOURCE_DIR}/3rdparty/gradle ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android-build/
                               COMMAND
                               ${CMAKE_COMMAND} -E copy_directory ${ANDROID_SOURCE_DIR}/android/templates ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android-build/
                               COMMAND
                               ${ANDROID_DEPLOY_QT} --input ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android_deployment_settings.json --output ${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}/android-build --android-platform android-${ANDROID_TARGET_SDK_VERSION} --jdk ${JDK_DIR} --gradle --aab --jarsigner ${ANDROID_DEPLOY_QT_CMD_ARGS})
        else ()
            if (NOT DEFINED ANDROID_ABI)
                message(FATAL_ERROR "When multi-building for Android, for each build the ANDROID_ABI must be set to the abi to build for. For example, ANDROID_ABI=armeabi-v7a|arm64-v8a|x86|x86_64")
            endif()
            message("Cross-compiling for Android. Building for the following abi: ${ANDROID_ABI}.")
            add_library(${TARGET_NAME} SHARED ${TARGET_ARGN})
            set_target_properties(${TARGET_NAME} PROPERTIES APP_BINARY_DIR ${APP_BINARY_DIR})
            set(ANDROID_MACRO_armeabi-v7a ANDROID_ARMEABI_V7A)
            set(ANDROID_MACRO_arm64-v8a ANDROID_ARM64_V8A)
            set(ANDROID_MACRO_x86 ANDROID_X86)
            set(ANDROID_MACRO_x86_64 ANDROID_X86_64)
            target_compile_definitions(${TARGET_NAME} PRIVATE ANDROID)
            target_compile_definitions(${TARGET_NAME} PRIVATE ${ANDROID_MACRO_${ANDROID_ABI}})
            add_custom_command(TARGET
                               ${TARGET_NAME}
                               POST_BUILD
                               COMMAND
                               ${CMAKE_COMMAND} -E make_directory ${APP_BINARY_DIR}
                               COMMAND
                               ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${TARGET_NAME}> ${APP_BINARY_DIR})
        endif()
    endfunction ()
    function (cute_add_library TARGET_NAME LIBRARY_TYPE)
        if (NOT "${ARGC}" EQUAL "2")
            message(FATAL_ERROR "Only the target name and the library type can be passed to cute_add_library. Add sources through target_sources command.")
        endif()
        if (NOT (${LIBRARY_TYPE} STREQUAL "STATIC"
            OR ${LIBRARY_TYPE} STREQUAL "SHARED"))
            message(FATAL_ERROR "When specifying a library with cute_add_library the second argument must be the library type having a value of either STATIC or SHARED.")
        endif()
        add_library(${TARGET_NAME} ${LIBRARY_TYPE} ${TARGET_ARGN})
        set(ANDROID_MACRO_armeabi-v7a ANDROID_ARMEABI_V7A)
        set(ANDROID_MACRO_arm64-v8a ANDROID_ARM64_V8A)
        set(ANDROID_MACRO_x86 ANDROID_X86)
        set(ANDROID_MACRO_x86_64 ANDROID_X86_64)
        target_compile_definitions(${TARGET_NAME} PRIVATE ANDROID)
        target_compile_definitions(${TARGET_NAME} PRIVATE ${ANDROID_MACRO_${ANDROID_ABI}})
    endfunction ()
elseif (UNIX)
    if (IS_FIRST_RUN)
        message("Build for UNIX host")
    endif()
    function (cute_add_executable TARGET_NAME)
        if (NOT "${ARGC}" EQUAL "1")
            message(FATAL_ERROR "Only the target name can be passed to cute_add_executable. Add sources through target_sources command.")
        endif()
        add_executable(${TARGET_NAME} ${ARGN})
        target_compile_definitions(${TARGET_NAME} PRIVATE UNIX)
    endfunction ()

    function (cute_add_library TARGET_NAME LIBRARY_TYPE)
        if (NOT "${ARGC}" EQUAL "2")
            message(FATAL_ERROR "Only the target name and the library type can be passed to cute_add_library. Add sources through target_sources command.")
        endif()
        if (NOT (${LIBRARY_TYPE} STREQUAL "STATIC"
            OR ${LIBRARY_TYPE} STREQUAL "SHARED"
            OR ${LIBRARY_TYPE} STREQUAL "MODULE"
            OR ${LIBRARY_TYPE} STREQUAL "OBJECT"))
            message(FATAL_ERROR "When specifying a library with cute_add_library the second argument must be the library type having a value of either STATIC, SHARED, MODULE or OBJECT.")
        endif()
        add_library(${TARGET_NAME} ${LIBRARY_TYPE} ${TARGET_ARGN})
        target_compile_definitions(${TARGET_NAME} PRIVATE UNIX)
    endfunction ()
elseif (WIN32)
        if (IS_FIRST_RUN)
            message("Build for Windows host")
        endif()
        # Setting option to remove path to pdb file from generated asset
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /PDBALTPATH:%_PDB%")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /PDBALTPATH:%_PDB%")
        function (cute_add_executable TARGET_NAME)
            if (NOT "${ARGC}" EQUAL "1")
                message(FATAL_ERROR "Only the target name can be passed to cute_add_executable. Add sources through target_sources command.")
            endif()
            add_executable(${TARGET_NAME} ${ARGN})
            target_compile_definitions(${TARGET_NAME} PRIVATE WINDOWS)
        endfunction ()

        function (cute_add_library TARGET_NAME LIBRARY_TYPE)
            if (NOT "${ARGC}" EQUAL "2")
                message(FATAL_ERROR "Only the target name and the library type can be passed to cute_add_library. Add sources through target_sources command.")
            endif()
            if (NOT (${LIBRARY_TYPE} STREQUAL "STATIC"
                    OR ${LIBRARY_TYPE} STREQUAL "SHARED"
                    OR ${LIBRARY_TYPE} STREQUAL "MODULE"
                    OR ${LIBRARY_TYPE} STREQUAL "OBJECT"))
                message(FATAL_ERROR "When specifying a library with cute_add_library the second argument must be the library type having a value of either STATIC, SHARED, MODULE or OBJECT.")
            endif()
            add_library(${TARGET_NAME} ${LIBRARY_TYPE} ${TARGET_ARGN})
            target_compile_definitions(${TARGET_NAME} PRIVATE WINDOWS)
        endfunction ()
endif()
