cmake_minimum_required(VERSION 3.28)
project(orion-start-menu
    VERSION 0.1.0
    DESCRIPTION "Orion OS Start Menu / launcher"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 DBus Concurrent)
find_package(OrionFramework 0.1 REQUIRED)

qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(orion-start-menu
    src/main.cpp
    src/appindex.cpp          src/appindex.h
    src/powercontrol.cpp      src/powercontrol.h
    src/startmenudbus.cpp     src/startmenudbus.h
    src/log.cpp               src/log.h
)

qt_add_qml_module(orion-start-menu
    URI org.orion.startmenu
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/SearchBar.qml
        qml/PinnedGrid.qml
        qml/AllAppsView.qml
        qml/RecommendedSection.qml
        qml/AppItem.qml
        qml/Footer.qml
)

target_link_libraries(orion-start-menu PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::DBus
    Qt6::Concurrent
    Orion::orion-framework
)

install(TARGETS orion-start-menu
    RUNTIME DESTINATION /usr/lib/orion
)
