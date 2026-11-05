cmake_minimum_required(VERSION 3.28)
project(orion-notifications VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 DBus)
find_package(OrionFramework 0.1 REQUIRED)
qt_standard_project_setup(REQUIRES 6.6)
qt_add_executable(orion-notifications
    src/main.cpp src/notificationsdaemon.cpp src/notificationsdaemon.h
    src/log.cpp src/log.h)
qt_add_qml_module(orion-notifications
    URI org.orion.notifications VERSION 1.0
    QML_FILES qml/Main.qml qml/NotificationCard.qml qml/NotificationStack.qml)
target_link_libraries(orion-notifications PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::DBus
    Orion::orion-framework)
install(TARGETS orion-notifications RUNTIME DESTINATION /usr/lib/orion)
