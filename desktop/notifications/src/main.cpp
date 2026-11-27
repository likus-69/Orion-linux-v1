// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-notifications entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: daemon.

#include "log.h"
#include "notificationsdaemon.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-notifications"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionNotifications) << "orion-notifications starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::NotificationsDaemon daemon;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("daemon"), &daemon);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.notifications"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionNotifications) << "Failed to load QML for orion-notifications";
        return -1;
    }

    return app.exec();
}
