# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# desktop/file-manager/CMakeLists.txt — Orion File Manager.
#
# A Windows-Explorer-style file manager for the Orion desktop.
# Qt6/QML, runs as a normal user, never escalates privileges.
# Wayland-native but works on X11 too.

cmake_minimum_required(VERSION 3.28)
project(orion-file-manager
    VERSION 0.1.0
    DESCRIPTION "Orion File Manager"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" FORCE)
endif()

# ---- Find Qt ---------------------------------------------------------------
find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickControls2 DBus Concurrent)
qt_standard_project_setup(REQUIRES 6.6)

# ---- Find OrionFramework ---------------------------------------------------
# Provides Orion::Theme, Orion::Settings, Orion::Log and the
# org.orion.framework QML module (OrionButton, OrionIcon, OrionMenu, ...).
find_package(OrionFramework 0.1 REQUIRED)

# ---- Sources ---------------------------------------------------------------
set(ORION_FM_SOURCES
    src/main.cpp
    src/filesystemmodel.cpp     src/filesystemmodel.h
    src/mountsmodel.cpp         src/mountsmodel.h
    src/placesmodel.cpp         src/placesmodel.h
    src/log.cpp                 src/log.h
)

qt_add_executable(orion-file-manager ${ORION_FM_SOURCES})

target_link_libraries(orion-file-manager PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::DBus
    Qt6::Concurrent
    Orion::orion-framework
)

# ---- QML resources ---------------------------------------------------------
# The QML files are bundled into a Qt resource so main.cpp can load
# qrc:/qml/Main.qml regardless of the install prefix. They are also
# installed on disk for hot-editing during development.
qt_add_resources(ORION_FM_QML_RESOURCES
    PREFIX "/qml"
    FILES
        qml/Main.qml
        qml/Breadcrumb.qml
        qml/FileItemDelegate.qml
        qml/Toolbar.qml
        qml/PlacesSidebar.qml
        qml/TabBar.qml
        qml/StatusBar.qml
)
target_sources(orion-file-manager PRIVATE ${ORION_FM_QML_RESOURCES})

# ---- Install ---------------------------------------------------------------
include(GNUInstallDirs)

# Binary goes to /usr/lib/orion/orion-file-manager so it matches the
# path expected by orion-file-manager.desktop.
install(TARGETS orion-file-manager
    RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}/orion)

# QML files are also installed on disk for hot-editing during development.
install(DIRECTORY qml/
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/orion/file-manager/qml
    FILES_MATCHING PATTERN "*.qml")
