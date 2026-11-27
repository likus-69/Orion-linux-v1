// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-software-center entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: packageKit, catalog.

#include "log.h"
#include "packagekitclient.h"
#include "appcatalog.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-software-center"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionSoftwareCenter) << "orion-software-center starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::PackageKitClient packageKit;
    Orion::AppCatalog catalog;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("packageKit"), &packageKit);
    engine.rootContext()->setContextProperty(QStringLiteral("catalog"), &catalog);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.software-center"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionSoftwareCenter) << "Failed to load QML for orion-software-center";
        return -1;
    }

    return app.exec();
}
