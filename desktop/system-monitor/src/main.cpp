// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-system-monitor entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: metrics.

#include "log.h"
#include "metrics.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-system-monitor"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionSystemMonitor) << "orion-system-monitor starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::Metrics metrics;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("metrics"), &metrics);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.system-monitor"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionSystemMonitor) << "Failed to load QML for orion-system-monitor";
        return -1;
    }

    return app.exec();
}
