// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-start-menu entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: appIndex, power, menuDbus.

#include "log.h"
#include "appindex.h"
#include "powercontrol.h"
#include "startmenudbus.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-start-menu"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionStartMenu) << "orion-start-menu starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::AppIndex appIndex;
    Orion::PowerControl power;
    Orion::StartMenuDBus menuDbus;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("appIndex"), &appIndex);
    engine.rootContext()->setContextProperty(QStringLiteral("power"), &power);
    engine.rootContext()->setContextProperty(QStringLiteral("menuDbus"), &menuDbus);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.start-menu"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionStartMenu) << "Failed to load QML for orion-start-menu";
        return -1;
    }

    return app.exec();
}
