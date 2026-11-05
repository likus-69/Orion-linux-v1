cmake_minimum_required(VERSION 3.28)
project(orion-welcome-center
    VERSION 0.1.0
    DESCRIPTION "Orion OS first-run welcome experience"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 DBus)
find_package(OrionFramework 0.1 REQUIRED)

qt_standard_project_setup(REQUIRES 6.6)

qt_add_executable(orion-welcome-center
    src/main.cpp
    src/welcomecontroller.cpp src/welcomecontroller.h
    src/log.cpp               src/log.h
)

qt_add_qml_module(orion-welcome-center
    URI org.orion.welcome
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/StepIndicator.qml
        qml/steps/WelcomeStep.qml
        qml/steps/NavigationStep.qml
        qml/steps/PersonalizationStep.qml
        qml/steps/NetworkStep.qml
        qml/steps/AudioStep.qml
        qml/steps/DisplayStep.qml
        qml/steps/HardwareStep.qml
        qml/steps/SoftwareStep.qml
        qml/steps/UpdateStep.qml
        qml/steps/BackupStep.qml
        qml/steps/PrivacyStep.qml
        qml/steps/DocsStep.qml
        qml/steps/DoneStep.qml
)

target_link_libraries(orion-welcome-center PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::DBus
    Orion::orion-framework
)

install(TARGETS orion-welcome-center RUNTIME DESTINATION /usr/lib/orion)
