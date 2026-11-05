cmake_minimum_required(VERSION 3.28)
project(orion-quick-settings VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 DBus)
find_package(OrionFramework 0.1 REQUIRED)
qt_standard_project_setup(REQUIRES 6.6)
qt_add_executable(orion-quick-settings
    src/main.cpp src/quickstate.cpp src/quickstate.h src/log.cpp src/log.h)
qt_add_qml_module(orion-quick-settings
    URI org.orion.quicksettings VERSION 1.0
    QML_FILES qml/Main.qml qml/WifiTile.qml qml/AudioTile.qml
              qml/PowerTile.qml qml/BluetoothTile.qml qml/QuickToggle.qml)
target_link_libraries(orion-quick-settings PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::DBus
    Orion::orion-framework)
install(TARGETS orion-quick-settings RUNTIME DESTINATION /usr/lib/orion)
