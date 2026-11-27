// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-lockscreen entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: locker.

#include "log.h"
#include "lockcontroller.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-lockscreen"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionLockscreen) << "orion-lockscreen starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::LockController locker;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("locker"), &locker);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.lockscreen"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionLockscreen) << "Failed to load QML for orion-lockscreen";
        return -1;
    }

    return app.exec();
}
