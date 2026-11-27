// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-update-manager entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: updates.

#include "log.h"
#include "updatemanager.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-update-manager"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionUpdateManager) << "orion-update-manager starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::UpdateManager updates;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("updates"), &updates);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.update-manager"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionUpdateManager) << "Failed to load QML for orion-update-manager";
        return -1;
    }

    return app.exec();
}
