// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-settings entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: controller.

#include "log.h"
#include "settingscontroller.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-settings"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionSettings) << "orion-settings starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::SettingsController controller;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("controller"), &controller);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionSettings) << "Failed to load QML for orion-settings";
        return -1;
    }

    return app.exec();
}
