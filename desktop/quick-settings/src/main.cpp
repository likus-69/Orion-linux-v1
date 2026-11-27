// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-quick-settings entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: quick.

#include "log.h"
#include "quickstate.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-quick-settings"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionQuickSettings) << "orion-quick-settings starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::QuickState quick;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("quick"), &quick);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.quick-settings"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionQuickSettings) << "Failed to load QML for orion-quick-settings";
        return -1;
    }

    return app.exec();
}
