cmake_minimum_required(VERSION 3.28)
project(orion-panel VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 DBus WaylandClient)
find_package(LayerShellQt QUIET)
find_package(OrionFramework 0.1 REQUIRED)
qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(orion-panel
    src/main.cpp
    src/kwinclient.cpp src/kwinclient.h
    src/pinnedapps.cpp src/pinnedapps.h
    src/log.cpp src/log.h)

qt_add_qml_module(orion-panel
    URI org.orion.panel VERSION 1.0
    QML_FILES qml/Main.qml qml/StartButton.qml qml/TaskbarItem.qml
              qml/SystemTray.qml qml/Clock.qml)

target_link_libraries(orion-panel PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::DBus
    Orion::orion-framework)

if(LayerShellQt_FOUND)
    target_link_libraries(orion-panel PRIVATE LayerShellQtInterface)
    target_compile_definitions(orion-panel PRIVATE ORION_HAVE_LAYER_SHELL=1)
endif()

install(TARGETS orion-panel RUNTIME DESTINATION /usr/lib/orion)
