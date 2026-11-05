cmake_minimum_required(VERSION 3.28)
project(orion-shell
    VERSION 0.1.0
    DESCRIPTION "Orion OS desktop shell (session launcher)"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core DBus)
find_package(OrionFramework 0.1 REQUIRED)

qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(orion-shell
    src/main.cpp
    src/sessionbus.cpp src/sessionbus.h
    src/log.cpp         src/log.h
)

target_link_libraries(orion-shell PRIVATE
    Qt6::Core
    Qt6::DBus
    Orion::orion-framework
)

# Install the binary at /usr/lib/orion/orion-shell so the wayland-sessions
# entry /usr/share/wayland-sessions/orion.desktop can exec it.
install(TARGETS orion-shell
    RUNTIME DESTINATION /usr/lib/orion
)
