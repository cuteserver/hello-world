#
# Copyright (c) 2022 Glauco Pacheco <glauco@cuteserver.io>
# All rights reserved
#

include(../CMake/Cute.cmake)

if (ANDROID)
#    set(KS_URL /home/glauco/Programming/AndroidKeystore/android.keystore)
#    set(KS_KEY_ALIAS AndroidDeveloperKeystore)
#    set(KS_PASS_FILE /home/glauco/Programming/AndroidKeystore/keystore.pass)
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/Android/PackageSource/Qt${QT_VERSION_MAJOR})
elseif (APPLE_MACOSX OR APPLE_IOS_DEVICE OR APPLE_IOS_SIMULATOR)
    set(MACOSX_BUNDLE True)
    #set(APPLE_CODE_SIGN_IDENTITY "Self-signed development certificate")
    set(MACOSX_BUNDLE_BUNDLE_NAME MyApp)
    set(MACOSX_BUNDLE_BUNDLE_VERSION 1.0.0)
    set(MACOSX_BUNDLE_COPYRIGHT glauco@cuteserver.io)
    set(MACOSX_BUNDLE_GUI_IDENTIFIER com.cuteserver.test.apple_app)
    set(MACOSX_BUNDLE_ICON_FILE AppIcon.icns)
    set(MACOSX_BUNDLE_INFO_STRING "made by myself")
    set(MACOSX_BUNDLE_LONG_VERSION_STRING "1.0.0 AE51344")
    set(MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0.0")
    set(SPLASH_SCREEN ${CMAKE_CURRENT_SOURCE_DIR}/Apple/MyAppSplashScreen.storyboard)
endif()

cute_add_executable(MyApp)
target_sources(MyApp PRIVATE Main.cpp qml.qrc)

if (NOT WASM)
    add_dependencies(MyApp MySharedLibrary)
endif()

if (ANDROID)
    # We are on Android. Thus, the dependent shared library
    # must be copied to the App's binary directory to make
    # it part of the app. We use the APP_BINARY_DIR property defined
    # by the toolchain.
    add_custom_command(TARGET
                       MyApp
                       POST_BUILD
                       COMMAND
                       ${CMAKE_COMMAND} -E make_directory $<TARGET_PROPERTY:MyApp,APP_BINARY_DIR>
                       COMMAND
                       ${CMAKE_COMMAND} -E echo "Copying $<TARGET_FILE:MySharedLibrary> to $<TARGET_PROPERTY:MyApp,APP_BINARY_DIR>"
                       COMMAND
                       ${CMAKE_COMMAND} -E copy $<TARGET_FILE:MySharedLibrary> $<TARGET_PROPERTY:MyApp,APP_BINARY_DIR>)
    if (${QT_VERSION_MAJOR} EQUAL 5)
        find_package(Qt${QT_VERSION_MAJOR} COMPONENTS AndroidExtras REQUIRED)
        target_link_libraries(MyApp PRIVATE
                              PRIVATE
                              Qt${QT_VERSION_MAJOR}::AndroidExtras)
    endif ()
elseif (APPLE_MACOSX)
    target_sources(MyApp PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Apple/macOS/AppIcon.icns)
    set_source_files_properties(${CMAKE_CURRENT_SOURCE_DIR}/Apple/macOS/AppIcon.icns PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    #
    # MySharedLibrary.framework does not get copied into the app bundles's frameworks folder.
    # Copying it here
    #
    add_custom_command(TARGET
                       MyApp
                       PRE_LINK
                       COMMAND
                       ${CMAKE_COMMAND} -E make_directory $<TARGET_BUNDLE_DIR:MyApp>/Contents/Frameworks/MySharedLibrary.framework
                       COMMAND
                       ${CMAKE_COMMAND} -E copy_directory $<TARGET_BUNDLE_DIR:MySharedLibrary> $<TARGET_BUNDLE_DIR:MyApp>/Contents/Frameworks/MySharedLibrary.framework
                       COMMAND
                       ${CMAKE_COMMAND} -E echo "Copying MySharedLibrary.framework into $<TARGET_BUNDLE_DIR:MyApp>")
elseif (APPLE_IOS_DEVICE OR APPLE_IOS_SIMULATOR)
    target_sources(MyApp PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/Apple/iOS/AppIcon.icns)
    set_source_files_properties(${CMAKE_CURRENT_SOURCE_DIR}/Apple/iOS/AppIcon.icns PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    add_custom_command(TARGET
                       MyApp
                       PRE_LINK
                       COMMAND
                       ${CMAKE_COMMAND} -E make_directory $<TARGET_BUNDLE_DIR:MyApp>/MySharedLibrary.framework
                       COMMAND
                       ${CMAKE_COMMAND} -E copy_directory $<TARGET_BUNDLE_DIR:MySharedLibrary> $<TARGET_BUNDLE_DIR:MyApp>/MySharedLibrary.framework
                       COMMAND
                       ${CMAKE_COMMAND} -E echo "Copying MySharedLibrary.framework into $<TARGET_BUNDLE_DIR:MyApp>")
endif()

if (WASM)
    find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Network Gui Qml Quick REQUIRED)
else ()
    find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Core Concurrent Network Gui Qml Quick REQUIRED)
endif ()

if (ANDROID)
    if (${QT_VERSION_MAJOR} EQUAL 5)
        find_package(Qt${QT_VERSION_MAJOR} COMPONENTS AndroidExtras REQUIRED)
    endif()
endif()

if (WASM)
    target_link_libraries(MyApp PRIVATE
                          Qt${QT_VERSION_MAJOR}::Core
                          Qt${QT_VERSION_MAJOR}::Network
                          Qt${QT_VERSION_MAJOR}::Gui
                          Qt${QT_VERSION_MAJOR}::Qml
                          Qt${QT_VERSION_MAJOR}::Quick)
else()
    target_link_libraries(MyApp PRIVATE
                          MySharedLibrary
                          Qt${QT_VERSION_MAJOR}::Core
                          Qt${QT_VERSION_MAJOR}::Concurrent
                          Qt${QT_VERSION_MAJOR}::Network
                          Qt${QT_VERSION_MAJOR}::Gui
                          Qt${QT_VERSION_MAJOR}::Qml
                          Qt${QT_VERSION_MAJOR}::Quick)
endif()

if (ANDROID)
    if (${QT_VERSION_MAJOR} EQUAL 5)
        target_link_libraries(MyApp PRIVATE
                              MySharedLibrary
                              Qt${QT_VERSION_MAJOR}::AndroidExtras)
    endif()
endif()

if (${QT_VERSION_MAJOR} EQUAL 6)
    qt6_import_qml_plugins(MyApp)
endif ()
