cmake_minimum_required(VERSION 3.28)
project(orion-system-monitor VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
find_package(OrionFramework 0.1 REQUIRED)
qt_standard_project_setup(REQUIRES 6.6)
qt_add_executable(orion-system-monitor src/main.cpp src/metrics.cpp src/metrics.h src/log.cpp src/log.h)
qt_add_qml_module(orion-system-monitor
    URI org.orion.systemmonitor VERSION 1.0
    QML_FILES qml/Main.qml qml/CpuChart.qml qml/MemoryChart.qml qml/ProcessList.qml)
target_link_libraries(orion-system-monitor PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Orion::orion-framework)
install(TARGETS orion-system-monitor RUNTIME DESTINATION /usr/lib/orion)
