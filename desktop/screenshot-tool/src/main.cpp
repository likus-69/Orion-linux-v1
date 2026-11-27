// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-screenshot-tool entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: shot.

#include "log.h"
#include "screenshot.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-screenshot-tool"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionScreenshot) << "orion-screenshot-tool starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::Screenshot shot;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("shot"), &shot);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.screenshot-tool"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionScreenshot) << "Failed to load QML for orion-screenshot-tool";
        return -1;
    }

    return app.exec();
}
