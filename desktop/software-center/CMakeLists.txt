cmake_minimum_required(VERSION 3.28)
project(orion-software-center
    VERSION 0.1.0
    DESCRIPTION "Orion OS graphical software center (PackageKit-backed)"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Concurrent DBus)
find_package(OrionFramework 0.1 REQUIRED)

qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(orion-software-center
    src/main.cpp
    src/packagekitclient.cpp src/packagekitclient.h
    src/appcatalog.cpp       src/appcatalog.h
    src/log.cpp              src/log.h
)

qt_add_qml_module(orion-software-center
    URI org.orion.softwarecenter
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Sidebar.qml
        qml/BrowsePage.qml
        qml/SearchPage.qml
        qml/InstalledPage.qml
        qml/UpdatesPage.qml
        qml/AppDetailPage.qml
        qml/AppCard.qml
        qml/RepoBadge.qml
        qml/InstallButton.qml
)

target_link_libraries(orion-software-center PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
    Qt6::Concurrent Qt6::DBus
    Orion::orion-framework
)

install(TARGETS orion-software-center RUNTIME DESTINATION /usr/lib/orion)
