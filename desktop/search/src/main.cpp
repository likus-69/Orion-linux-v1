// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-search entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: searchIndex.

#include "log.h"
#include "searchindex.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-search"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionSearch) << "orion-search starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::SearchIndex searchIndex;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("searchIndex"), &searchIndex);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.search"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionSearch) << "Failed to load QML for orion-search";
        return -1;
    }

    return app.exec();
}
