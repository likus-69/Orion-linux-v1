// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/main.cpp — Orion Shell entry point.
//
// The Orion Shell is the Wayland session leader. It is the binary that
// SDDM execs when the user picks the "Orion" entry in the wayland-sessions
// menu (see /usr/share/wayland-sessions/orion.desktop). Its responsibilities:
//
//   1. Install the Orion structured log handler.
//   2. Acquire the `org.orion.Shell` D-Bus name (so other Orion components
//      know the session is up and so the lockscreen can talk to it).
//   3. Start the user-facing desktop components as systemd user services:
//      orion-panel, orion-notifications, orion-quick-settings, orion-search,
//      orion-start-menu, orion-update-manager. Using systemd user units
//      means each component is restartable, journalable, and ordered
//      correctly with the session.
//   4. Block until the session ends (received SIGHUP/SIGTERM from logind
//      when the user logs out, or the user runs `systemctl --user exit`).
//
// The shell itself does NOT draw anything to the screen. The panel, the
// start menu, etc. are separate processes that connect to the same Wayland
// compositor (KWin) and render their own surfaces.

#include "sessionbus.h"
#include "log.h"

#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusPendingCall>
#include <QProcess>
#include <QScopeGuard>
#include <QTimer>
#include <QtCore/qglobal.h>

#include <csignal>
#include <cstdio>

namespace {
volatile std::sig_atomic_t g_exitRequested = 0;

void signalHandler(int sig)
{
    g_exitRequested = sig;
}
}  // namespace

static bool startUserService(const QString &unit)
{
    QProcess p;
    p.setProgram(QStringLiteral("systemctl"));
    p.setArguments({ QStringLiteral("--user"), QStringLiteral("start"), unit });
    p.start();
    if (!p.waitForFinished(3000)) {
        qCWarning(orionShell) << "systemctl --user start" << unit << "timed out";
        return false;
    }
    if (p.exitCode() != 0) {
        qCWarning(orionShell) << "systemctl --user start" << unit
                               << "failed with exit code" << p.exitCode();
        return false;
    }
    qCInfo(orionShell) << "Started user service:" << unit;
    return true;
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-shell"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    // Use Qt's default message handler (journald-aware on systemd hosts).
    // Components that want Orion's structured format can call
    // Orion::Log::installHandler() from the framework — the shell itself
    // is small enough that Qt's default is fine.
    qCInfo(orionShell) << "Orion Shell starting up";

    // ---- Acquire D-Bus name -------------------------------------------------
    Orion::SessionBus bus;
    if (!bus.acquireName()) {
        qCCritical(orionShell) << "Another Orion Shell instance appears to be running. Exiting.";
        return 1;
    }

    // ---- Start user-facing desktop components -------------------------------
    // These are started as systemd user units so each is independently
    // restartable, journalable, and ordered with the session. If a unit
    // fails to start, we log but do not abort — the desktop should
    // degrade gracefully (CONTRIBUTING.md §23 rule 18).
    const QStringList services = {
        QStringLiteral("orion-panel.service"),
        QStringLiteral("orion-notifications.service"),
        QStringLiteral("orion-quick-settings.service"),
        QStringLiteral("orion-search.service"),
        QStringLiteral("orion-start-menu.service"),
        QStringLiteral("orion-update-manager.service"),
    };
    for (const QString &unit : services) {
        startUserService(unit);
    }

    // ---- Install signal handlers --------------------------------------------
    std::signal(SIGHUP,  signalHandler);
    std::signal(SIGTERM, signalHandler);
    std::signal(SIGINT,  signalHandler);

    // Poll for signal arrival every 500ms. Using a timer rather than a
    // signal-handler QSocketNotifier keeps the code simple and portable.
    QTimer exitPoller;
    exitPoller.setInterval(500);
    QObject::connect(&exitPoller, &QTimer::timeout, &app, [&]() {
        if (g_exitRequested != 0) {
            qCInfo(orionShell) << "Received signal" << g_exitRequested << "; exiting.";
            app.quit();
        }
    });
    exitPoller.start();

    // ---- Run ----------------------------------------------------------------
    const int exitCode = app.exec();

    // ---- Tear down user services on graceful exit ---------------------------
    qCInfo(orionShell) << "Orion Shell exiting with code" << exitCode;
    for (const QString &unit : services) {
        QProcess p;
        p.setProgram(QStringLiteral("systemctl"));
        p.setArguments({ QStringLiteral("--user"), QStringLiteral("stop"), unit });
        p.start();
        p.waitForFinished(2000);
    }
    return exitCode;
}
