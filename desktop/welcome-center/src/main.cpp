// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-welcome-center entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: welcome.

#include "log.h"
#include "welcomecontroller.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-welcome-center"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionWelcomeCenter) << "orion-welcome-center starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::WelcomeController welcome;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("welcome"), &welcome);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.welcome-center"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionWelcomeCenter) << "Failed to load QML for orion-welcome-center";
        return -1;
    }

    return app.exec();
}
