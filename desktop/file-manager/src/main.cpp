// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — orion-file-manager entry point.
//
// Loads qml/Main.qml and exposes the controller instance(s) as context
// properties: fileSystem, mounts, places.

#include "log.h"
#include "filesystemmodel.h"
#include "mountsmodel.h"
#include "placesmodel.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-file-manager"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionFileManager) << "orion-file-manager starting up";

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::FileSystemModel fileSystem;
    Orion::MountsModel mounts;
    Orion::PlacesModel places;

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("fileSystem"), &fileSystem);
    engine.rootContext()->setContextProperty(QStringLiteral("mounts"), &mounts);
    engine.rootContext()->setContextProperty(QStringLiteral("places"), &places);

    engine.load(QUrl(QStringLiteral("qrc:/qml/Main.qml")));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionFileManager) << "Failed to load QML for orion-file-manager";
        return -1;
    }

    return app.exec();
}
