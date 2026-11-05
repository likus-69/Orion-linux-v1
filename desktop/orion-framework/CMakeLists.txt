cmake_minimum_required(VERSION 3.28)
project(orion-framework
    VERSION 0.1.0
    DESCRIPTION "Orion OS shared framework library"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Default to RelWithDebInfo for non-Debug builds.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" FORCE)
endif()

option(BUILD_TESTING "Build tests" OFF)
option(ORION_BUILD_DEMOS "Build the demo application" OFF)

# ---- Find Qt ---------------------------------------------------------------
find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
qt_standard_project_setup(REQUIRES 6.6)

# ---- Library ---------------------------------------------------------------
qt_add_library(orion-framework SHARED
    src/theme.cpp            src/theme.h
    src/color.cpp            src/color.h
    src/typography.cpp       src/typography.h
    src/tokens.cpp           src/tokens.h
    src/settings.cpp         src/settings.h
    src/log.cpp              src/log.h
    src/about.cpp            src/about.h
    src/hardware.cpp         src/hardware.h
)

qt_add_qml_module(orion-framework
    URI org.orion.framework
    VERSION 1.0
    QML_FILES
        qml/Theme.qml
        qml/OrionButton.qml
        qml/OrionCard.qml
        qml/OrionListRow.qml
        qml/OrionTextField.qml
        qml/OrionComboBox.qml
        qml/OrionSwitch.qml
        qml/OrionSlider.qml
        qml/OrionDialog.qml
        qml/OrionTooltip.qml
        qml/OrionIcon.qml
        qml/OrionLabel.qml
        qml/OrionMenu.qml
        qml/OrionTabBar.qml
        qml/OrionBusy.qml
    RESOURCES
        data/tokens.json
)

target_include_directories(orion-framework
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
        $<INSTALL_INTERFACE:include/orion-framework>
)

target_link_libraries(orion-framework
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
)

set_target_properties(orion-framework PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
)

# ---- Self-test binary ------------------------------------------------------
add_executable(orion-framework-selftest src/selftest.cpp)
target_link_libraries(orion-framework-selftest PRIVATE orion-framework Qt6::Core)

# ---- Tests -----------------------------------------------------------------
if(BUILD_TESTING)
    enable_testing()
    find_package(Qt6 REQUIRED COMPONENTS Test)
    add_executable(test_theme tests/test_theme.cpp)
    target_link_libraries(test_theme PRIVATE orion-framework Qt6::Test)
    add_test(NAME test_theme COMMAND test_theme)
endif()

# ---- Install ---------------------------------------------------------------
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(TARGETS orion-framework
    EXPORT OrionFrameworkTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/orion-framework
)

install(DIRECTORY src/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/orion-framework
    FILES_MATCHING PATTERN "*.h"
)

install(EXPORT OrionFrameworkTargets
    FILE OrionFrameworkTargets.cmake
    NAMESPACE Orion::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OrionFramework
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/OrionFrameworkConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/OrionFrameworkConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OrionFramework
)

write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/OrionFrameworkConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/OrionFrameworkConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/OrionFrameworkConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/OrionFramework
)

install(TARGETS orion-framework-selftest
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
