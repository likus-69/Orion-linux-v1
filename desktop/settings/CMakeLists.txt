# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# desktop/settings/CMakeLists.txt — Orion Settings.
#
# Unified Windows-Settings-style control panel covering 7 categories:
# Personalization, System, Devices, Network, Accounts, Privacy & Security,
# Applications. Built on Qt6/QML and the Orion framework. Runs as a
# normal user; all privileged operations go through polkit (login1,
# hostname1, timedate1, locale1, accountsService, NetworkManager, udisks2,
# ufw/nftables via systemctl, etc.) — the binary is never setuid and
# never expects to be run as root.

cmake_minimum_required(VERSION 3.28)
project(orion-settings
    VERSION 0.1.0
    DESCRIPTION "Orion OS Settings"
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
find_package(Qt6 6.6 REQUIRED COMPONENTS
    Core Gui Widgets Qml Quick QuickControls2 DBus Concurrent)
qt_standard_project_setup(REQUIRES 6.6)

# ---- Find OrionFramework ---------------------------------------------------
# Provides Orion::Theme / Orion::Settings / Orion::Log and the
# org.orion.framework QML module (OrionButton, OrionCard, OrionListRow,
# OrionTextField, OrionComboBox, OrionSwitch, OrionSlider, OrionDialog,
# OrionTooltip, OrionIcon, OrionLabel, OrionMenu, OrionTabBar, OrionBusy).
find_package(OrionFramework 0.1 REQUIRED)

# ---- Sources ---------------------------------------------------------------
set(ORION_SETTINGS_SOURCES
    src/main.cpp
    src/settingscontroller.cpp     src/settingscontroller.h
    src/log.cpp                   src/log.h
)

qt_add_executable(orion-settings ${ORION_SETTINGS_SOURCES})

target_link_libraries(orion-settings PRIVATE
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
# Bundled into a Qt resource so main.cpp can load qrc:/qml/Main.qml
# regardless of install prefix. The QML files are also installed on disk
# under /usr/share/orion/settings/qml/ for hot-editing during development.
qt_add_resources(ORION_SETTINGS_QML_RESOURCES
    PREFIX "/qml"
    FILES
        qml/Main.qml
        qml/Sidebar.qml
        qml/components/ThemeCard.qml
        qml/components/AccentSwatch.qml
        qml/pages/PersonalizationPage.qml
        qml/pages/SystemPage.qml
        qml/pages/DevicesPage.qml
        qml/pages/NetworkPage.qml
        qml/pages/AccountsPage.qml
        qml/pages/PrivacyPage.qml
        qml/pages/ApplicationsPage.qml
)
target_sources(orion-settings PRIVATE ${ORION_SETTINGS_QML_RESOURCES})

# ---- Install ---------------------------------------------------------------
include(GNUInstallDirs)

# Binary goes to /usr/lib/orion/orion-settings so it matches the path
# expected by orion-settings.desktop.
install(TARGETS orion-settings
    RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}/orion)

# QML files are also installed on disk for hot-editing during development.
install(DIRECTORY qml/
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/orion/settings/qml
    FILES_MATCHING PATTERN "*.qml")
