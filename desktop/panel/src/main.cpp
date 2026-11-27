// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — Orion Panel entry point.
//
// Loads qml/Main.qml from the `org.orion.panel` QML module (registered by
// qt_add_qml_module in CMakeLists.txt) and exposes three context properties
// that the QML expects:
//
//   - panelSettings: Orion::Settings bound to "panel" (reads panel height,
//                    layout, etc. from ~/.config/orion/panel.json)
//   - panelPinned:   Orion::PinnedApps (the pinned-app list)
//   - panelKWin:     Orion::KWinClient (the running-window list)
//
// The panel window itself is anchored to the bottom of the screen by
// LayerShellQt when that library is available (detected at CMake time
// via find_package(LayerShellQt)). Without LayerShellQt the panel is a
// frameless window positioned at the bottom of the primary screen.

#include "log.h"
#include "kwinclient.h"
#include "pinnedapps.h"

#include "settings.h"  // Orion::Settings from orion-framework (on include path via Orion::orion-framework)

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QScreen>
#include <QTimer>

#ifdef ORION_HAVE_LAYER_SHELL
#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-panel"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    qCInfo(orionPanel) << "Orion Panel starting up";

#ifdef ORION_HAVE_LAYER_SHELL
    LayerShellQt::Shell::useLayerShell();
#endif

    // ---- Context properties (must outlive the engine) ----------------------
    Orion::Settings  panelSettings(QStringLiteral("panel"));
    Orion::PinnedApps panelPinned;
    Orion::KWinClient panelKWin;

    // Refresh the KWin window list every 1s. The list itself is empty until
    // TODO: Plasma window-management protocol integration lands (see
    // kwinclient.cpp), but the polling structure is in place.
    QTimer kwinPoller;
    kwinPoller.setInterval(1000);
    QObject::connect(&kwinPoller, &QTimer::timeout, &panelKWin,
                     QOverload<>::of(&Orion::KWinClient::refresh));
    kwinPoller.start();

    // ---- Load QML -----------------------------------------------------------
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(QStringLiteral("panelSettings"), &panelSettings);
    engine.rootContext()->setContextProperty(QStringLiteral("panelPinned"),   &panelPinned);
    engine.rootContext()->setContextProperty(QStringLiteral("panelKWin"),     &panelKWin);

    // The panel's QML module is registered with URI org.orion.panel by
    // qt_add_qml_module in CMakeLists.txt. We load Main.qml via loadFromModule.
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule(QStringLiteral("org.orion.panel"), QStringLiteral("Main"));

    if (engine.rootObjects().isEmpty()) {
        qCCritical(orionPanel) << "Failed to load panel QML";
        return -1;
    }

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    if (!window) {
        qCCritical(orionPanel) << "Panel root object is not a QQuickWindow";
        return -1;
    }

#ifdef ORION_HAVE_LAYER_SHELL
    auto *layerWindow = LayerShellQt::Window::get(window);
    if (layerWindow) {
        layerWindow->setAnchor(LayerShellQt::Window::AnchorBottom);
        layerWindow->setLayer(LayerShellQt::Window::LayerTop);
        layerWindow->setExclusiveZone(window->height());
        layerWindow->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
        qCInfo(orionPanel) << "Anchored panel to bottom via LayerShellQt";
    } else {
        qCWarning(orionPanel) << "LayerShellQt enabled but Window::get returned null";
    }
#else
    // Fallback: position the window at the bottom of the primary screen.
    // The QML already does this (ApplicationWindow y: Screen.height - panelHeight),
    // so we don't need to duplicate the positioning here.
    Q_UNUSED(window);
#endif

    return app.exec();
}
