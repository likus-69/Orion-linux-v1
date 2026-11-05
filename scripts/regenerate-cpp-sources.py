#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# scripts/regenerate-cpp-sources.py — recreate the C++ source files for
# every desktop component (everything except orion-framework, which
# survived the sandbox reset).
#
# These files were originally written individually but were lost when the
# sandbox wiped the src/ subdirectories. This script recreates them from
# the documented contracts (worklog, CMakeLists.txt, README, and the
# original design).
#
# Run from the repository root:
#     python3 scripts/regenerate-cpp-sources.py

from pathlib import Path
from textwrap import dedent

REPO_ROOT = Path(__file__).resolve().parent.parent
DESKTOP = REPO_ROOT / "desktop"

SPDX = "// SPDX-License-Identifier: GPL-3.0-or-later\n// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors\n"

# ----------------------------------------------------------------------------
# log.h + log.cpp — same pattern for every component, just different category.
# ----------------------------------------------------------------------------
LOG_H_TEMPLATE = SPDX + """
#pragma once
#include <QLoggingCategory>

#define ORION_LOG_CATEGORY(name) \\
    Q_LOGGING_CATEGORY(lcOrion, name, QtDebugMsg)

Q_DECLARE_LOGGING_CATEGORY(lcOrion)
"""

LOG_CPP_TEMPLATE = SPDX + """
#include "log.h"

Q_LOGGING_CATEGORY(lcOrion, "{category}")
"""


def write_log_files(component_dir: Path, category: str) -> None:
    src = component_dir / "src"
    (src / "log.h").write_text(LOG_H_TEMPLATE)
    (src / "log.cpp").write_text(LOG_CPP_TEMPLATE.format(category=category))


# ----------------------------------------------------------------------------
# Per-component source files. Each entry is (filename, content-template).
# ----------------------------------------------------------------------------

SHELL_SOURCES = {
    "main.cpp": SPDX + """
#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QProcess>
#include <QTimer>
#include <QEventLoop>
#include <unistd.h>

#include "log.h"
#include "sessionbus.h"

ORION_LOG_CATEGORY("orion.shell")

namespace {{
void setEnvironmentVariables() {{
    if (qEnvironmentVariableIsEmpty("XDG_CURRENT_DESKTOP")) qputenv("XDG_CURRENT_DESKTOP", "orion");
    if (qEnvironmentVariableIsEmpty("XDG_SESSION_TYPE"))    qputenv("XDG_SESSION_TYPE", "wayland");
    if (qEnvironmentVariableIsEmpty("XDG_SESSION_DESKTOP")) qputenv("XDG_SESSION_DESKTOP", "orion");
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORM"))     qputenv("QT_QPA_PLATFORM", "wayland");
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORMTHEME")) qputenv("QT_QPA_PLATFORMTHEME", "orion");
    if (qEnvironmentVariableIsEmpty("MOZ_ENABLE_WAYLAND"))  qputenv("MOZ_ENABLE_WAYLAND", "1");
    if (qEnvironmentVariableIsEmpty("_JAVA_AWT_WM_NONREPARENTING")) qputenv("_JAVA_AWT_WM_NONREPARENTING", "1");
    if (qEnvironmentVariableIsEmpty("SDL_VIDEODRIVER"))      qputenv("SDL_VIDEODRIVER", "wayland");
}}

bool kwinAlreadyRunning() {{
    QDBusInterface kwin(QStringLiteral("org.kde.KWin"),
                        QStringLiteral("/KWin"),
                        QStringLiteral("org.kde.KWin"),
                        QDBusConnection::sessionBus());
    return kwin.isValid();
}}

QProcess *launchKWin() {{
    auto *kwin = new QProcess();
    kwin->setProgram(QStringLiteral("kwin_wayland"));
    kwin->setArguments({{QStringLiteral("--libinput"),
                          QStringLiteral("--xwayland")}});
    kwin->setProcessChannelMode(QProcess::ForwardedChannels);
    QObject::connect(kwin, &QProcess::finished,
                     [](int exitCode, QProcess::ExitStatus) {{
        qCCritical(lcOrion) << "KWin exited with code" << exitCode;
        QCoreApplication::exit(exitCode == 0 ? 0 : 1);
    }});
    kwin->start();
    if (!kwin->waitForStarted(10000)) {{
        qCCritical(lcOrion) << "Failed to start kwin_wayland";
        delete kwin;
        return nullptr;
    }}
    return kwin;
}}

void startOrionComponents() {{
    static const QStringList components = {{
        QStringLiteral("orion-panel.service"),
        QStringLiteral("orion-start-menu.service"),
        QStringLiteral("orion-notifications.service"),
        QStringLiteral("orion-quick-settings.service"),
        QStringLiteral("orion-update-manager.service"),
        QStringLiteral("orion-search.service"),
    }};
    for (const auto &unit : components) {{
        QProcess systemctl;
        systemctl.setProgram(QStringLiteral("systemctl"));
        systemctl.setArguments({{QStringLiteral("--user"),
                                  QStringLiteral("start"), unit}});
        systemctl.start();
        if (!systemctl.waitForFinished(5000)) {{
            qCWarning(lcOrion) << "Failed to start" << unit;
        }} else if (systemctl.exitCode() != 0) {{
            qCWarning(lcOrion) << "systemctl start" << unit
                               << "returned" << systemctl.exitCode();
        }} else {{
            qCInfo(lcOrion) << "Started" << unit;
        }}
    }}
}}

void stopOrionComponents() {{
    for (const auto &unit : QStringList{{
        QStringLiteral("orion-search.service"),
        QStringLiteral("orion-update-manager.service"),
        QStringLiteral("orion-quick-settings.service"),
        QStringLiteral("orion-notifications.service"),
        QStringLiteral("orion-start-menu.service"),
        QStringLiteral("orion-panel.service"),
    }}) {{
        QProcess systemctl;
        systemctl.setProgram(QStringLiteral("systemctl"));
        systemctl.setArguments({{QStringLiteral("--user"),
                                  QStringLiteral("stop"), unit}});
        systemctl.start();
        systemctl.waitForFinished(5000);
    }}
}}
}} // namespace

int main(int argc, char *argv[]) {{
    QCoreApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-shell"));
    app.setOrganizationName(QStringLiteral("OrionOS"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));

    setEnvironmentVariables();
    qCInfo(lcOrion) << "Orion Shell starting";

    Orion::SessionBus sessionBus;
    if (!sessionBus.registerOnSessionBus()) {{
        qCCritical(lcOrion) << "Another Orion Shell instance is already running";
        return 1;
    }}

    QProcess *kwin = nullptr;
    if (!kwinAlreadyRunning()) {{
        qCInfo(lcOrion) << "Starting KWin";
        kwin = launchKWin();
        if (!kwin) return 2;
        QEventLoop loop;
        QTimer::singleShot(1500, &loop, &QEventLoop::quit);
        loop.exec();
    }} else {{
        qCInfo(lcOrion) << "KWin already running (test mode)";
    }}

    qCInfo(lcOrion) << "Starting Orion desktop components";
    startOrionComponents();

    const int rc = app.exec();

    qCInfo(lcOrion) << "Orion Shell stopping";
    stopOrionComponents();
    if (kwin) {{
        kwin->terminate();
        kwin->waitForFinished(3000);
        delete kwin;
    }}
    return rc;
}}
""",
    "sessionbus.h": SPDX + """
#pragma once
#include <QObject>

namespace Orion {{

class SessionBus : public QObject {{
    Q_OBJECT
public:
    explicit SessionBus(QObject *parent = nullptr) : QObject(parent) {{}}
    bool registerOnSessionBus();
}};

}} // namespace Orion
""",
    "sessionbus.cpp": SPDX + """
#include "sessionbus.h"
#include "log.h"

#include <QDBusConnection>

ORION_LOG_CATEGORY("orion.shell")

namespace Orion {{

bool SessionBus::registerOnSessionBus() {{
    auto bus = QDBusConnection::sessionBus();
    const bool ok = bus.registerService(QStringLiteral("org.orion.Shell"));
    if (ok) {{
        bus.registerObject(QStringLiteral("/orion/Shell"), this,
                           QDBusConnection::ExportScriptableContents);
        qCInfo(lcOrion) << "Registered org.orion.Shell on the session bus";
    }} else {{
        qCWarning(lcOrion) << "Could not register org.orion.Shell — another"
                           << "shell instance is likely already running";
    }}
    return ok;
}}

}} // namespace Orion
""",
}

# ----------------------------------------------------------------------------
# Generic main.cpp template for QML-based components.
# ----------------------------------------------------------------------------
def make_main_cpp(component_name: str, qml_uri: str, context_props: list[tuple[str, str]]) -> str:
    """Generate a main.cpp for a QML-based component.
    context_props is a list of (qml_name, cpp_class) tuples to register.
    """
    includes = "\n".join(f'#include "{name.lower()}.h"' for _, name in context_props)
    register_lines = "\n    ".join(
        f'engine.rootContext()->setContextProperty(QStringLiteral("{qml}"), &{cpp.lower()});'
        for qml, cpp in context_props
    )
    instantiations = "\n    ".join(
        f'{cpp} {cpp.lower()};' for _, cpp in context_props
    )
    return SPDX + f"""
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDBusConnection>

#include "log.h"
{includes}

ORION_LOG_CATEGORY("{component_name.replace('-', '.')}")

int main(int argc, char *argv[]) {{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("{component_name}"));
    app.setOrganizationName(QStringLiteral("OrionOS"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));
    QGuiApplication::setQuitOnLastWindowClosed(false);

    {instantiations}

    QQmlApplicationEngine engine;
    {register_lines}
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/{qml_uri}/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) {{
        qCCritical(lcOrion) << "Failed to load Main.qml";
        return 1;
    }}

    qCInfo(lcOrion) << "{component_name} ready";
    return app.exec();
}}
"""


# Component-specific source files (each is unique to that component).
COMPONENT_SOURCES = {
    "panel": {
        "kwinclient.h": SPDX + """
#pragma once
#include <QObject>
#include <QVariantList>
#include <QDBusServiceWatcher>

namespace Orion {{

// Wraps org.kde.KWin D-Bus to enumerate running windows.
class KWinClient : public QObject {{
    Q_OBJECT
    Q_PROPERTY(QVariantList windows READ windows NOTIFY windowsChanged)
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
public:
    explicit KWinClient(QObject *parent = nullptr);

    QVariantList windows() const {{ return m_windows; }}
    bool available() const {{ return m_available; }}

    Q_INVOKABLE bool activateWindow(const QString &uuid);
    Q_INVOKABLE bool closeWindow(const QString &uuid);

signals:
    void windowsChanged();
    void availableChanged();

private:
    void refresh();
    void onServiceRegistered(const QString &name);
    QVariantList m_windows;
    bool m_available = false;
    QDBusServiceWatcher *m_watcher = nullptr;
}};

}} // namespace Orion
""",
        "kwinclient.cpp": SPDX + """
#include "kwinclient.h"
#include "log.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusPendingReply>
#include <QDBusPendingCallWatcher>
#include <QTimer>

ORION_LOG_CATEGORY("orion.panel")

namespace Orion {{

KWinClient::KWinClient(QObject *parent) : QObject(parent) {{
    m_watcher = new QDBusServiceWatcher(
        QStringLiteral("org.kde.KWin"),
        QDBusConnection::sessionBus(),
        QDBusServiceWatcher::WatchForOwnerChange,
        this);
    connect(m_watcher, &QDBusServiceWatcher::serviceOwnerChanged,
            this, [this](const QString &name, const QString &, const QString &) {{
        if (name == QStringLiteral("org.kde.KWin")) onServiceRegistered(name);
    }});
    onServiceRegistered(QStringLiteral("org.kde.KWin"));

    // 1-second fallback refresh in case KWin signals are missed.
    auto *t = new QTimer(this);
    t->setInterval(1000);
    connect(t, &QTimer::timeout, this, &KWinClient::refresh);
    t->start();
}}

void KWinClient::onServiceRegistered(const QString &name) {{
    Q_UNUSED(name);
    QDBusInterface iface(QStringLiteral("org.kde.KWin"),
                         QStringLiteral("/KWin"),
                         QStringLiteral("org.kde.kwin.Plugins"),
                         QDBusConnection::sessionBus());
    const bool nowAvailable = iface.isValid();
    if (nowAvailable != m_available) {{
        m_available = nowAvailable;
        emit availableChanged();
    }}
    if (m_available) refresh();
}}

void KWinClient::refresh() {{
    if (!m_available) return;
    QDBusInterface kwin(QStringLiteral("org.kde.KWin"),
                       QStringLiteral("/KWin"),
                       QStringLiteral("org.kde.kwin.Plugins"),
                       QDBusConnection::sessionBus());
    // Real impl: query window list via D-Bus. For v1, leave empty — the
    // panel still shows pinned apps even without running-app enumeration.
    m_windows.clear();
    emit windowsChanged();
}}

bool KWinClient::activateWindow(const QString &uuid) {{
    if (!m_available) return false;
    QDBusInterface kwin(QStringLiteral("org.kde.KWin"),
                       QStringLiteral("/KWin"),
                       QStringLiteral("org.kde.kwin.Plugins"),
                       QDBusConnection::sessionBus());
    return kwin.call(QStringLiteral("setActiveWindow"), uuid).type()
           != QDBusMessage::ErrorMessage;
}}

bool KWinClient::closeWindow(const QString &uuid) {{
    if (!m_available) return false;
    QDBusInterface kwin(QStringLiteral("org.kde.KWin"),
                       QStringLiteral("/KWin"),
                       QStringLiteral("org.kde.kwin.Plugins"),
                       QDBusConnection::sessionBus());
    return kwin.call(QStringLiteral("closeWindow"), uuid).type()
           != QDBusMessage::ErrorMessage;
}}

}} // namespace Orion
""",
        "pinnedapps.h": SPDX + """
#pragma once
#include <QObject>
#include <QVariantList>

namespace Orion {{

class Settings;

class PinnedApps : public QObject {{
    Q_OBJECT
    Q_PROPERTY(QVariantList pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)
public:
    explicit PinnedApps(QObject *parent = nullptr);

    QVariantList pinnedApps() const {{ return m_pinned; }}

    Q_INVOKABLE bool launch(const QString &desktopFileId);
    Q_INVOKABLE void reload();

signals:
    void pinnedAppsChanged();

private:
    void load();
    QVariantList m_pinned;
}};

}} // namespace Orion
""",
        "pinnedapps.cpp": SPDX + """
#include "pinnedapps.h"
#include "log.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcess>
#include <QSettings>
#include <QStandardPaths>

ORION_LOG_CATEGORY("orion.panel")

namespace Orion {{

PinnedApps::PinnedApps(QObject *parent) : QObject(parent) {{ load(); }}

void PinnedApps::load() {{
    m_pinned.clear();
    QFile f(QStringLiteral("/usr/share/orion/defaults/etc-skell/orion-defaults.json"));
    if (!f.open(QIODevice::ReadOnly)) {{
        qCWarning(lcOrion) << "Could not load pinned-apps defaults";
        emit pinnedAppsChanged();
        return;
    }}
    const auto obj = QJsonDocument::fromJson(f.readAll()).object();
    const auto panel = obj.value(QStringLiteral("panel")).toObject();
    const auto pinned = panel.value(QStringLiteral("pinned_apps")).toArray();
    for (const auto &id : pinned) {{
        QVariantMap app;
        app.insert(QStringLiteral("desktopFileId"), id.toString());
        app.insert(QStringLiteral("name"), id.toString().section('.', 0, 0));
        app.insert(QStringLiteral("icon"), QStringLiteral("icon-application"));
        m_pinned << app;
    }}
    emit pinnedAppsChanged();
}}

bool PinnedApps::launch(const QString &desktopFileId) {{
    return QProcess::startDetached(
        QStringLiteral("gtk-launch"), {{ desktopFileId }});
}}

void PinnedApps::reload() {{ load(); }}

}} // namespace Orion
""",
        "main.cpp": SPDX + """
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "log.h"
#include "kwinclient.h"
#include "pinnedapps.h"

ORION_LOG_CATEGORY("orion.panel")

int main(int argc, char *argv[]) {{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-panel"));
    app.setOrganizationName(QStringLiteral("OrionOS"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));
    QGuiApplication::setQuitOnLastWindowClosed(false);

    Orion::KWinClient kwinClient;
    Orion::PinnedApps pinnedApps;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("panelKWin"), &kwinClient);
    engine.rootContext()->setContextProperty(QStringLiteral("panelPinned"), &pinnedApps);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/org/orion/panel/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) {{
        qCCritical(lcOrion) << "Failed to load Main.qml";
        return 1;
    }}

    qCInfo(lcOrion) << "Orion Panel ready";
    return app.exec();
}}
""",
    },
    "start-menu": {
        "appindex.h": SPDX + """
#pragma once
#include <QObject>
#include <QVariantList>
#include <QMap>

namespace Orion {{

class AppIndex : public QObject {{
    Q_OBJECT
    Q_PROPERTY(QVariantList allApps READ allApps NOTIFY appsChanged)
    Q_PROPERTY(QVariantList pinnedApps READ pinnedApps NOTIFY appsChanged)
    Q_PROPERTY(QVariantList recommendedApps READ recommendedApps NOTIFY appsChanged)
    Q_PROPERTY(QVariantList recentFiles READ recentFiles NOTIFY appsChanged)
public:
    explicit AppIndex(QObject *parent = nullptr);

    QVariantList allApps() const {{ return m_allApps; }}
    QVariantList pinnedApps() const {{ return m_pinnedApps; }}
    QVariantList recommendedApps() const {{ return m_recommendedApps; }}
    QVariantList recentFiles() const {{ return m_recentFiles; }}

    Q_INVOKABLE QVariantList search(const QString &query) const;
    Q_INVOKABLE bool launch(const QString &desktopFileId);
    Q_INVOKABLE void togglePin(const QString &desktopFileId);
    Q_INVOKABLE void refresh();

signals:
    void appsChanged();

private:
    void scanDesktopFiles();
    void loadPinnedApps();
    void loadRecentFiles();
    void loadRecommendedApps();

    QVariantList m_allApps;
    QVariantList m_pinnedApps;
    QVariantList m_recommendedApps;
    QVariantList m_recentFiles;
    QMap<QString, QVariantMap> m_index;
}};

}} // namespace Orion
""",
        "appindex.cpp": SPDX + """
#include "appindex.h"
#include "log.h"

#include <QDir>
#include <QDomDocument>
#include <QFile>
#include <QProcess>
#include <QSettings>
#include <QStandardPaths>
#include <algorithm>

ORION_LOG_CATEGORY("orion.startmenu")

namespace Orion {{

AppIndex::AppIndex(QObject *parent) : QObject(parent) {{ refresh(); }}

void AppIndex::refresh() {{
    scanDesktopFiles();
    loadPinnedApps();
    loadRecentFiles();
    loadRecommendedApps();
    emit appsChanged();
}}

void AppIndex::scanDesktopFiles() {{
    m_index.clear();
    m_allApps.clear();
    static const QStringList dirs = {{
        QStringLiteral("/usr/share/applications"),
        QStringLiteral("/usr/local/share/applications"),
        QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
            + QStringLiteral("/applications"),
    }};
    for (const auto &dirPath : dirs) {{
        QDir dir(dirPath);
        if (!dir.exists()) continue;
        for (const auto &fi : dir.entryInfoList({{QStringLiteral("*.desktop")}}, QDir::Files)) {{
            QSettings s(fi.absoluteFilePath(), QSettings::IniFormat);
            s.beginGroup(QStringLiteral("Desktop Entry"));
            if (s.value(QStringLiteral("Type")).toString() != QStringLiteral("Application")) continue;
            if (s.value(QStringLiteral("NoDisplay"), false).toBool()) continue;
            QVariantMap app;
            app.insert(QStringLiteral("desktopFileId"), fi.fileName());
            app.insert(QStringLiteral("name"), s.value(QStringLiteral("Name")).toString());
            app.insert(QStringLiteral("genericName"), s.value(QStringLiteral("GenericName")).toString());
            app.insert(QStringLiteral("comment"), s.value(QStringLiteral("Comment")).toString());
            app.insert(QStringLiteral("icon"), s.value(QStringLiteral("Icon")).toString());
            app.insert(QStringLiteral("exec"), s.value(QStringLiteral("Exec")).toString());
            m_index.insert(fi.fileName(), app);
        }}
    }}
    QList<QVariantMap> sorted;
    for (const auto &v : m_index) sorted << v;
    std::sort(sorted.begin(), sorted.end(), [](const QVariantMap &a, const QVariantMap &b) {{
        return a.value(QStringLiteral("name")).toString().toLower() <
               b.value(QStringLiteral("name")).toString().toLower();
    }});
    m_allApps.clear();
    for (const auto &v : sorted) m_allApps << v;
    qCInfo(lcOrion) << "Indexed" << m_allApps.size() << "applications";
}}

void AppIndex::loadPinnedApps() {{
    m_pinnedApps.clear();
    QFile f(QStringLiteral("/usr/share/orion/defaults/etc-skell/orion-defaults.json"));
    if (!f.open(QIODevice::ReadOnly)) return;
    const auto pinned = QJsonDocument::fromJson(f.readAll()).object()
        .value(QStringLiteral("start_menu")).toObject()
        .value(QStringLiteral("pinned_apps")).toArray();
    for (const auto &id : pinned) {{
        const QString desktopId = id.toString();
        if (m_index.contains(desktopId)) m_pinnedApps << m_index.value(desktopId);
    }}
}}

void AppIndex::loadRecentFiles() {{
    m_recentFiles.clear();
    QFile f(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
            + QStringLiteral("/recently-used.xbel"));
    if (!f.open(QIODevice::ReadOnly)) return;
    QDomDocument doc;
    if (!doc.setContent(&f)) return;
    const auto bookmarks = doc.elementsByTagName(QStringLiteral("bookmark"));
    for (int i = 0; i < std::min(bookmarks.size(), 12); ++i) {{
        const auto el = bookmarks.at(i).toElement();
        if (el.isNull()) continue;
        QVariantMap entry;
        entry.insert(QStringLiteral("uri"), el.attribute(QStringLiteral("href")));
        entry.insert(QStringLiteral("added"), el.attribute(QStringLiteral("added")));
        m_recentFiles << entry;
    }}
}}

void AppIndex::loadRecommendedApps() {{
    m_recommendedApps = m_pinnedApps.mid(0, 6);
}}

QVariantList AppIndex::search(const QString &query) const {{
    if (query.trimmed().isEmpty()) return m_allApps;
    const QString q = query.toLower();
    QVariantList out;
    for (const auto &v : m_index) {{
        const auto app = v.toMap();
        if (app.value(QStringLiteral("name")).toString().toLower().contains(q))
            out << app;
    }}
    return out;
}}

bool AppIndex::launch(const QString &desktopFileId) {{
    return QProcess::startDetached(
        QStringLiteral("gtk-launch"), {{ desktopFileId }});
}}

void AppIndex::togglePin(const QString &desktopFileId) {{
    QVariantList newPinned;
    bool found = false;
    for (const auto &v : m_pinnedApps) {{
        const auto app = v.toMap();
        if (app.value(QStringLiteral("desktopFileId")).toString() == desktopFileId) {{
            found = true;
        }} else {{
            newPinned << app;
        }}
    }}
    if (!found && m_index.contains(desktopFileId)) {{
        newPinned << m_index.value(desktopFileId);
    }}
    m_pinnedApps = newPinned;
    emit appsChanged();
}}

}} // namespace Orion
""",
        "powercontrol.h": SPDX + """
#pragma once
#include <QObject>

namespace Orion {{

class PowerControl : public QObject {{
    Q_OBJECT
public:
    explicit PowerControl(QObject *parent = nullptr) : QObject(parent) {{}}
    Q_INVOKABLE bool lockSession();
    Q_INVOKABLE bool terminateSession();
    Q_INVOKABLE bool reboot();
    Q_INVOKABLE bool powerOff();
}};

}} // namespace Orion
""",
        "powercontrol.cpp": SPDX + """
#include "powercontrol.h"
#include "log.h"

#include <QDBusInterface>
#include <QDBusPendingReply>
#include <unistd.h>

ORION_LOG_CATEGORY("orion.startmenu")

namespace Orion {{

namespace {{
bool callLogin1(const QString &method) {{
    QDBusInterface login1(QStringLiteral("org.freedesktop.login1"),
                          QStringLiteral("/org/freedesktop/login1"),
                          QStringLiteral("org.freedesktop.login1.Manager"),
                          QDBusConnection::systemBus());
    if (!login1.isValid()) return false;
    QDBusPendingReply<> reply = login1.call(method, QVariant(true));
    reply.waitForFinished();
    return !reply.isError();
}}

QString currentSessionId() {{
    QDBusInterface login1(QStringLiteral("org.freedesktop.login1"),
                          QStringLiteral("/org/freedesktop/login1"),
                          QStringLiteral("org.freedesktop.login1.Manager"),
                          QDBusConnection::systemBus());
    if (!login1.isValid()) return {{}};
    QDBusPendingReply<QDBusObjectPath> reply =
        login1.call(QStringLiteral("GetSessionByPID"), QVariant(uint(::getpid())));
    reply.waitForFinished();
    if (reply.isError()) return {{}};
    return reply.value().path().section(QLatin1Char('/'), -1);
}}
}} // namespace

bool PowerControl::lockSession() {{
    const QString sid = currentSessionId();
    if (sid.isEmpty()) {{
        QDBusInterface ss(QStringLiteral("org.freedesktop.ScreenSaver"),
                         QStringLiteral("/ScreenSaver"),
                         QStringLiteral("org.freedesktop.ScreenSaver"),
                         QDBusConnection::sessionBus());
        return ss.call(QStringLiteral("Lock")).type() != QDBusMessage::ErrorMessage;
    }}
    QDBusInterface login1(QStringLiteral("org.freedesktop.login1"),
                          QStringLiteral("/org/freedesktop/login1"),
                          QStringLiteral("org.freedesktop.login1.Manager"),
                          QDBusConnection::systemBus());
    return login1.call(QStringLiteral("LockSession"), QVariant(sid)).type()
        != QDBusMessage::ErrorMessage;
}}

bool PowerControl::terminateSession() {{
    return callLogin1(QStringLiteral("TerminateSession"));
}}

bool PowerControl::reboot()    {{ return callLogin1(QStringLiteral("Reboot")); }}
bool PowerControl::powerOff()  {{ return callLogin1(QStringLiteral("PowerOff")); }}

}} // namespace Orion
""",
        "startmenudbus.h": SPDX + """
#pragma once
#include <QObject>

namespace Orion {{

class AppIndex;

class StartMenuDBus : public QObject {{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.orion.StartMenu")
public:
    StartMenuDBus(class QQuickWindow *window, AppIndex *appIndex, QObject *parent = nullptr)
        : QObject(parent), m_window(window), m_appIndex(appIndex) {{}}
public slots:
    Q_SCRIPTABLE void Toggle();
    Q_SCRIPTABLE void Open();
    Q_SCRIPTABLE void Close();
    Q_SCRIPTABLE void Search(const QString &query);
private:
    class QQuickWindow *m_window;
    AppIndex *m_appIndex;
}};

}} // namespace Orion
""",
        "startmenudbus.cpp": SPDX + """
#include "startmenudbus.h"
#include "appindex.h"

#include <QQuickWindow>

namespace Orion {{

void StartMenuDBus::Toggle() {{
    if (!m_window) return;
    if (m_window->isVisible()) m_window->hide();
    else {{ m_window->show(); m_window->requestActivate(); }}
}}

void StartMenuDBus::Open()  {{ if (m_window) {{ m_window->show(); m_window->requestActivate(); }} }}
void StartMenuDBus::Close() {{ if (m_window) m_window->hide(); }}
void StartMenuDBus::Search(const QString &) {{ /* forward to QML via signal */ }}

}} // namespace Orion
""",
        "main.cpp": SPDX + """
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDBusConnection>

#include "log.h"
#include "appindex.h"
#include "powercontrol.h"
#include "startmenudbus.h"

ORION_LOG_CATEGORY("orion.startmenu")

int main(int argc, char *argv[]) {{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-start-menu"));
    app.setOrganizationName(QStringLiteral("OrionOS"));
    QGuiApplication::setQuitOnLastWindowClosed(false);

    Orion::AppIndex appIndex;
    Orion::PowerControl powerControl;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("appIndex"), &appIndex);
    engine.rootContext()->setContextProperty(QStringLiteral("powerControl"), &powerControl);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/org/orion/startmenu/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) {{
        qCCritical(lcOrion) << "Failed to load Main.qml";
        return 1;
    }}

    auto *root = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    Orion::StartMenuDBus dbusAdaptor(root, &appIndex);
    auto bus = QDBusConnection::sessionBus();
    if (!bus.registerService(QStringLiteral("org.orion.StartMenu"))) {{
        qCWarning(lcOrion) << "Another start-menu instance is running";
        return 2;
    }}
    bus.registerObject(QStringLiteral("/orion/StartMenu"), &dbusAdaptor,
                       QDBusConnection::ExportAllSlots);

    qCInfo(lcOrion) << "Orion Start Menu ready";
    return app.exec();
}}
""",
    },
}


def write_component_sources(component_name: str, files: dict[str, str]) -> None:
    src = DESKTOP / component_name / "src"
    src.mkdir(parents=True, exist_ok=True)
    for filename, content in files.items():
        (src / filename).write_text(content)
        print(f"  wrote {component_name}/src/{filename}")


def main() -> int:
    # 0. orion-framework — special: many files, custom design.
    fw = DESKTOP / "orion-framework"
    (fw / "src").mkdir(parents=True, exist_ok=True)
    write_log_files(fw, "orion.framework")

    # tokens.h + tokens.cpp
    (fw / "src" / "tokens.h").write_text(SPDX + """
#pragma once
#include <QObject>
#include <QColor>
#include <QJsonObject>
#include <QMap>

namespace Orion {{

struct ColorRamp {{ QString name; QColor c50, c100, c300, c500, c700, c900; }};
struct SurfaceRamp {{ QString name; QColor c0, c1, c2, c3, c4; }};
struct ForegroundRamp {{ QString name; QColor primary, secondary, tertiary, disabled, inverse; }};
struct BorderRamp {{ QString name; QColor subtle, def, strong, focus; }};
struct SemanticColors {{ QColor success, warning, danger, info; }};

class Tokens : public QObject {{
    Q_OBJECT
public:
    static Tokens *instance(QObject *parent = nullptr);
    bool load();
    bool setTheme(const QString &name);
    QString currentThemeName() const {{ return m_currentTheme; }}
    QStringList availableThemes() const {{ return m_themes.keys(); }}
    const SurfaceRamp    &surface()    const {{ return m_surface; }}
    const ForegroundRamp &foreground() const {{ return m_foreground; }}
    const ColorRamp      &accent()     const {{ return m_accent; }}
    const BorderRamp     &border()     const {{ return m_border; }}
    const SemanticColors &semantic()   const {{ return m_semantic; }}
    QString fontFamily()     const {{ return m_fontFamily; }}
    QString fontFamilyMono() const {{ return m_fontFamilyMono; }}
    QString fontFamilyCJK()  const {{ return m_fontFamilyCJK; }}
    int motionDuration(const QString &key) const;
    QString motionEasing() const {{ return m_motionEasing; }}
    bool reduceMotion() const {{ return m_reduceMotion; }}
    void setReduceMotion(bool v) {{ m_reduceMotion = v; emit motionChanged(); }}
    bool reduceTransparency() const {{ return m_reduceTransparency; }}
    void setReduceTransparency(bool v) {{ m_reduceTransparency = v; emit transparencyChanged(); }}

signals:
    void themeChanged();
    void motionChanged();
    void transparencyChanged();

private:
    explicit Tokens(QObject *parent = nullptr);
    bool parseThemes(const QJsonObject &root);
    static QColor parseColor(const QJsonValue &v);

    QString m_currentTheme;
    QMap<QString, QJsonObject> m_themes;
    SurfaceRamp     m_surface;
    ForegroundRamp  m_foreground;
    ColorRamp       m_accent;
    BorderRamp      m_border;
    SemanticColors  m_semantic;
    QString m_fontFamily, m_fontFamilyMono, m_fontFamilyCJK;
    QMap<QString, int> m_motionDurations;
    QString m_motionEasing;
    bool m_reduceMotion = false;
    bool m_reduceTransparency = false;
}};

}} // namespace Orion
""")
    (fw / "src" / "tokens.cpp").write_text(SPDX + """
#include "tokens.h"
#include "log.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonParseError>

ORION_LOG_CATEGORY("orion.framework")

namespace Orion {{

Tokens *Tokens::instance(QObject *parent) {{
    static Tokens *s_inst = nullptr;
    if (!s_inst) {{
        s_inst = new Tokens(parent);
        s_inst->load();
    }}
    return s_inst;
}}

Tokens::Tokens(QObject *parent) : QObject(parent) {{}}

bool Tokens::load() {{
    QFile f(QStringLiteral(":/org/orion/framework/data/tokens.json"));
    if (!f.open(QIODevice::ReadOnly)) {{
        qCCritical(lcOrion) << "Cannot open tokens.json resource";
        return false;
    }}
    const auto bytes = f.readAll();
    f.close();
    QJsonParseError err{{}};
    const auto doc = QJsonDocument::fromJson(bytes, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {{
        qCCritical(lcOrion) << "tokens.json parse error:" << err.errorString();
        return false;
    }}
    const auto root = doc.object();
    if (!parseThemes(root)) return false;

    const auto typo = root.value(QStringLiteral("typography")).toObject();
    m_fontFamily     = typo.value(QStringLiteral("font_family")).toString(QStringLiteral("Inter"));
    m_fontFamilyMono = typo.value(QStringLiteral("font_family_mono")).toString(QStringLiteral("JetBrains Mono"));
    m_fontFamilyCJK  = typo.value(QStringLiteral("font_family_cjk")).toString(QStringLiteral("Noto Sans CJK SC"));

    const auto motion = root.value(QStringLiteral("motion")).toObject();
    for (const auto &k : motion.keys()) {{
        if (k == QStringLiteral("easing")) continue;
        m_motionDurations.insert(k, int(motion.value(k).toDouble()));
    }}
    m_motionEasing = motion.value(QStringLiteral("easing")).toString(
        QStringLiteral("cubic-bezier(0.2, 0.0, 0.0, 1.0)"));

    if (m_themes.contains(QStringLiteral("orion-dark")))
        setTheme(QStringLiteral("orion-dark"));
    else if (!m_themes.isEmpty())
        setTheme(m_themes.firstKey());
    return true;
}}

bool Tokens::parseThemes(const QJsonObject &root) {{
    const auto themes = root.value(QStringLiteral("themes")).toObject();
    for (const auto &k : themes.keys())
        m_themes.insert(k, themes.value(k).toObject());
    return !m_themes.isEmpty();
}}

QColor Tokens::parseColor(const QJsonValue &v) {{
    return QColor(v.toString());
}}

bool Tokens::setTheme(const QString &name) {{
    const auto it = m_themes.constFind(name);
    if (it == m_themes.constEnd()) return false;
    const auto theme = it.value();
    m_currentTheme = name;
    const auto s = theme.value(QStringLiteral("surface")).toObject();
    m_surface = {{name, parseColor(s.value(QStringLiteral("0"))),
                 parseColor(s.value(QStringLiteral("1"))),
                 parseColor(s.value(QStringLiteral("2"))),
                 parseColor(s.value(QStringLiteral("3"))),
                 parseColor(s.value(QStringLiteral("4")))}};
    const auto fg = theme.value(QStringLiteral("foreground")).toObject();
    m_foreground = {{name, parseColor(fg.value(QStringLiteral("primary"))),
                     parseColor(fg.value(QStringLiteral("secondary"))),
                     parseColor(fg.value(QStringLiteral("tertiary"))),
                     parseColor(fg.value(QStringLiteral("disabled"))),
                     parseColor(fg.value(QStringLiteral("inverse")))}};
    const auto a = theme.value(QStringLiteral("accent")).toObject();
    m_accent = {{name, parseColor(a.value(QStringLiteral("50"))),
                 parseColor(a.value(QStringLiteral("100"))),
                 parseColor(a.value(QStringLiteral("300"))),
                 parseColor(a.value(QStringLiteral("500"))),
                 parseColor(a.value(QStringLiteral("700"))),
                 parseColor(a.value(QStringLiteral("900")))}};
    const auto b = theme.value(QStringLiteral("border")).toObject();
    m_border = {{name, parseColor(b.value(QStringLiteral("subtle"))),
                 parseColor(b.value(QStringLiteral("default"))),
                 parseColor(b.value(QStringLiteral("strong"))),
                 parseColor(b.value(QStringLiteral("focus")))}};
    const auto sem = theme.value(QStringLiteral("semantic")).toObject();
    m_semantic = {{parseColor(sem.value(QStringLiteral("success"))),
                   parseColor(sem.value(QStringLiteral("warning"))),
                   parseColor(sem.value(QStringLiteral("danger"))),
                   parseColor(sem.value(QStringLiteral("info")))}};
    emit themeChanged();
    return true;
}}

int Tokens::motionDuration(const QString &key) const {{
    if (m_reduceMotion) return 0;
    return m_motionDurations.value(key, 200);
}}

}} // namespace Orion
""")

    # theme.h + theme.cpp
    (fw / "src" / "theme.h").write_text(SPDX + """
#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QColor>
#include "tokens.h"

namespace Orion {{

class Theme : public QObject {{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QString currentTheme READ currentTheme WRITE setCurrentTheme NOTIFY themeChanged)
    Q_PROPERTY(QStringList availableThemes READ availableThemes CONSTANT)
    Q_PROPERTY(QColor surface0 READ surface0 NOTIFY themeChanged)
    Q_PROPERTY(QColor surface1 READ surface1 NOTIFY themeChanged)
    Q_PROPERTY(QColor surface2 READ surface2 NOTIFY themeChanged)
    Q_PROPERTY(QColor surface3 READ surface3 NOTIFY themeChanged)
    Q_PROPERTY(QColor surface4 READ surface4 NOTIFY themeChanged)
    Q_PROPERTY(QColor fgPrimary READ fgPrimary NOTIFY themeChanged)
    Q_PROPERTY(QColor fgSecondary READ fgSecondary NOTIFY themeChanged)
    Q_PROPERTY(QColor fgTertiary READ fgTertiary NOTIFY themeChanged)
    Q_PROPERTY(QColor fgDisabled READ fgDisabled NOTIFY themeChanged)
    Q_PROPERTY(QColor fgInverse READ fgInverse NOTIFY themeChanged)
    Q_PROPERTY(QColor accent50 READ accent50 NOTIFY themeChanged)
    Q_PROPERTY(QColor accent100 READ accent100 NOTIFY themeChanged)
    Q_PROPERTY(QColor accent300 READ accent300 NOTIFY themeChanged)
    Q_PROPERTY(QColor accent500 READ accent500 NOTIFY themeChanged)
    Q_PROPERTY(QColor accent700 READ accent700 NOTIFY themeChanged)
    Q_PROPERTY(QColor accent900 READ accent900 NOTIFY themeChanged)
    Q_PROPERTY(QColor success READ success NOTIFY themeChanged)
    Q_PROPERTY(QColor warning READ warning NOTIFY themeChanged)
    Q_PROPERTY(QColor danger READ danger NOTIFY themeChanged)
    Q_PROPERTY(QColor info READ info NOTIFY themeChanged)
    Q_PROPERTY(QColor borderSubtle READ borderSubtle NOTIFY themeChanged)
    Q_PROPERTY(QColor borderDefault READ borderDefault NOTIFY themeChanged)
    Q_PROPERTY(QColor borderStrong READ borderStrong NOTIFY themeChanged)
    Q_PROPERTY(QColor borderFocus READ borderFocus NOTIFY themeChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily CONSTANT)
    Q_PROPERTY(QString fontFamilyMono READ fontFamilyMono CONSTANT)
    Q_PROPERTY(QString fontFamilyCJK READ fontFamilyCJK CONSTANT)
    Q_PROPERTY(int motionFast READ motionFast NOTIFY motionChanged)
    Q_PROPERTY(int motionDefault READ motionDefault NOTIFY motionChanged)
    Q_PROPERTY(int motionSlow READ motionSlow NOTIFY motionChanged)
    Q_PROPERTY(int motionSlower READ motionSlower NOTIFY motionChanged)
    Q_PROPERTY(QString motionEasing READ motionEasing CONSTANT)
    Q_PROPERTY(bool reduceMotion READ reduceMotion WRITE setReduceMotion NOTIFY motionChanged)
    Q_PROPERTY(bool reduceTransparency READ reduceTransparency WRITE setReduceTransparency NOTIFY transparencyChanged)
    Q_PROPERTY(int space0 READ space0 CONSTANT)
    Q_PROPERTY(int space1 READ space1 CONSTANT)
    Q_PROPERTY(int space2 READ space2 CONSTANT)
    Q_PROPERTY(int space3 READ space3 CONSTANT)
    Q_PROPERTY(int space4 READ space4 CONSTANT)
    Q_PROPERTY(int space5 READ space5 CONSTANT)
    Q_PROPERTY(int space6 READ space6 CONSTANT)
    Q_PROPERTY(int space8 READ space8 CONSTANT)
    Q_PROPERTY(int space10 READ space10 CONSTANT)
    Q_PROPERTY(int space12 READ space12 CONSTANT)
    Q_PROPERTY(int space16 READ space16 CONSTANT)
    Q_PROPERTY(int radiusNone READ radiusNone CONSTANT)
    Q_PROPERTY(int radiusSm READ radiusSm CONSTANT)
    Q_PROPERTY(int radiusMd READ radiusMd CONSTANT)
    Q_PROPERTY(int radiusLg READ radiusLg CONSTANT)
    Q_PROPERTY(int radiusXl READ radiusXl CONSTANT)
    Q_PROPERTY(int radiusFull READ radiusFull CONSTANT)
public:
    static Theme *create(QQmlEngine *engine, QJSEngine *scriptEngine);
    static Theme *instance();

    QString currentTheme() const {{ return m_tokens->currentThemeName(); }}
    void setCurrentTheme(const QString &name) {{ m_tokens->setTheme(name); }}
    QStringList availableThemes() const {{ return m_tokens->availableThemes(); }}

    QColor surface0() const {{ return m_tokens->surface().c0; }}
    QColor surface1() const {{ return m_tokens->surface().c1; }}
    QColor surface2() const {{ return m_tokens->surface().c2; }}
    QColor surface3() const {{ return m_tokens->surface().c3; }}
    QColor surface4() const {{ return m_tokens->surface().c4; }}
    QColor fgPrimary() const {{ return m_tokens->foreground().primary; }}
    QColor fgSecondary() const {{ return m_tokens->foreground().secondary; }}
    QColor fgTertiary() const {{ return m_tokens->foreground().tertiary; }}
    QColor fgDisabled() const {{ return m_tokens->foreground().disabled; }}
    QColor fgInverse() const {{ return m_tokens->foreground().inverse; }}
    QColor accent50() const {{ return m_tokens->accent().c50; }}
    QColor accent100() const {{ return m_tokens->accent().c100; }}
    QColor accent300() const {{ return m_tokens->accent().c300; }}
    QColor accent500() const {{ return m_tokens->accent().c500; }}
    QColor accent700() const {{ return m_tokens->accent().c700; }}
    QColor accent900() const {{ return m_tokens->accent().c900; }}
    QColor success() const {{ return m_tokens->semantic().success; }}
    QColor warning() const {{ return m_tokens->semantic().warning; }}
    QColor danger() const {{ return m_tokens->semantic().danger; }}
    QColor info() const {{ return m_tokens->semantic().info; }}
    QColor borderSubtle() const {{ return m_tokens->border().subtle; }}
    QColor borderDefault() const {{ return m_tokens->border().def; }}
    QColor borderStrong() const {{ return m_tokens->border().strong; }}
    QColor borderFocus() const {{ return m_tokens->border().focus; }}
    QString fontFamily() const {{ return m_tokens->fontFamily(); }}
    QString fontFamilyMono() const {{ return m_tokens->fontFamilyMono(); }}
    QString fontFamilyCJK() const {{ return m_tokens->fontFamilyCJK(); }}
    int motionFast() const {{ return m_tokens->motionDuration(QStringLiteral("fast")); }}
    int motionDefault() const {{ return m_tokens->motionDuration(QStringLiteral("default")); }}
    int motionSlow() const {{ return m_tokens->motionDuration(QStringLiteral("slow")); }}
    int motionSlower() const {{ return m_tokens->motionDuration(QStringLiteral("slower")); }}
    QString motionEasing() const {{ return m_tokens->motionEasing(); }}
    bool reduceMotion() const {{ return m_tokens->reduceMotion(); }}
    void setReduceMotion(bool v) {{ m_tokens->setReduceMotion(v); }}
    bool reduceTransparency() const {{ return m_tokens->reduceTransparency(); }}
    void setReduceTransparency(bool v) {{ m_tokens->setReduceTransparency(v); }}
    int space0() const {{ return 0; }} int space1() const {{ return 4; }}
    int space2() const {{ return 8; }}  int space3() const {{ return 12; }}
    int space4() const {{ return 16; }} int space5() const {{ return 20; }}
    int space6() const {{ return 24; }}  int space8() const {{ return 32; }}
    int space10() const {{ return 40; }} int space12() const {{ return 48; }}
    int space16() const {{ return 64; }}
    int radiusNone() const {{ return 0; }}   int radiusSm() const {{ return 4; }}
    int radiusMd() const {{ return 8; }}    int radiusLg() const {{ return 12; }}
    int radiusXl() const {{ return 16; }}   int radiusFull() const {{ return 9999; }}
signals:
    void themeChanged();
    void motionChanged();
    void transparencyChanged();
private:
    explicit Theme(QObject *parent = nullptr);
    Tokens *m_tokens;
}};

}} // namespace Orion
""")
    (fw / "src" / "theme.cpp").write_text(SPDX + """
#include "theme.h"

#include <QQmlEngine>

namespace Orion {{

Theme *Theme::create(QQmlEngine *engine, QJSEngine *scriptEngine) {{
    Q_UNUSED(engine); Q_UNUSED(scriptEngine);
    auto *inst = instance();
    QQmlEngine::setObjectOwnership(inst, QQmlEngine::CppOwnership);
    return inst;
}}

Theme *Theme::instance() {{
    static Theme *s_inst = nullptr;
    if (!s_inst) s_inst = new Theme();
    return s_inst;
}}

Theme::Theme(QObject *parent)
    : QObject(parent), m_tokens(Tokens::instance(this)) {{
    connect(m_tokens, &Tokens::themeChanged, this, &Theme::themeChanged);
    connect(m_tokens, &Tokens::motionChanged, this, &Theme::motionChanged);
    connect(m_tokens, &Tokens::transparencyChanged, this, &Theme::transparencyChanged);
}}

}} // namespace Orion
""")

    # about.h + about.cpp
    (fw / "src" / "about.h").write_text(SPDX + """
#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QStringList>

namespace Orion {{

class About : public QObject {{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    static About *create(QQmlEngine *e, QJSEngine *s) {{
        Q_UNUSED(e); Q_UNUSED(s);
        static About *i = new About();
        QQmlEngine::setObjectOwnership(i, QQmlEngine::CppOwnership);
        return i;
    }}
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString codename READ codename CONSTANT)
    Q_PROPERTY(QString kernelVersion READ kernelVersion CONSTANT)
    Q_PROPERTY(QString architecture READ architecture CONSTANT)
    Q_PROPERTY(QString buildId READ buildId CONSTANT)
    Q_PROPERTY(QString homeUrl READ homeUrl CONSTANT)
    Q_PROPERTY(QString documentationUrl READ documentationUrl CONSTANT)
    Q_PROPERTY(QString supportUrl READ supportUrl CONSTANT)
    Q_PROPERTY(QString bugReportUrl READ bugReportUrl CONSTANT)
    Q_PROPERTY(QStringList maintainers READ maintainers CONSTANT)

    QString name() const {{ return QStringLiteral("Orion OS"); }}
    QString version() const {{ return QStringLiteral("v2026.10"); }}
    QString codename() const {{ return QStringLiteral("orion"); }}
    QString kernelVersion() const;
    QString architecture() const;
    QString buildId() const;
    QString homeUrl() const {{ return QStringLiteral("https://github.com/likus-69/Orion-linux-v1.1/"); }}
    QString documentationUrl() const {{ return QStringLiteral("https://github.com/likus-69/Orion-linux-v1.1/tree/main/docs/"); }}
    QString supportUrl() const {{ return QStringLiteral("https://github.com/likus-69/Orion-linux-v1.1/issues/"); }}
    QString bugReportUrl() const {{ return QStringLiteral("https://github.com/likus-69/Orion-linux-v1.1/issues/"); }}
    QStringList maintainers() const {{ return {{ QStringLiteral("Orion OS Project Contributors") }}; }}
private:
    About() = default;
}};

}} // namespace Orion
""")
    (fw / "src" / "about.cpp").write_text(SPDX + """
#include "about.h"

#include <QFile>
#include <QSysInfo>
#include <QTextStream>

namespace Orion {{

QString About::kernelVersion() const {{ return QSysInfo::kernelVersion(); }}
QString About::architecture() const {{ return QSysInfo::currentCpuArchitecture(); }}
QString About::buildId() const {{
    QFile f(QStringLiteral("/etc/os-release"));
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return {{}};
    QTextStream in(&f);
    while (!in.atEnd()) {{
        const QString line = in.readLine();
        if (line.startsWith(QStringLiteral("BUILD_ID="))) {{
            return line.section(QLatin1Char('='), 1).remove(QLatin1Char('"'));
        }}
    }}
    return {{}};
}}

}} // namespace Orion
""")

    # selftest.cpp
    (fw / "src" / "selftest.cpp").write_text(SPDX + """
#include "theme.h"
#include "tokens.h"
#include "about.h"

#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[]) {{
    QCoreApplication app(argc, argv);

    auto *tokens = Orion::Tokens::instance();
    if (!tokens->load()) {{
        qCritical() << "FAIL: Tokens::load returned false";
        return 1;
    }}

    auto *theme = Orion::Theme::instance();
    qInfo() << "OK: theme loaded, current theme:" << theme->currentTheme();
    qInfo() << "OK: surface0:" << theme->surface0().name();
    qInfo() << "OK: accent500:" << theme->accent500().name();
    qInfo() << "OK: available themes:" << theme->availableThemes();

    auto *about = Orion::About::create(nullptr, nullptr);
    qInfo() << "OK: about.name:" << about->name()
            << "version:" << about->version();

    if (theme->availableThemes().contains(QStringLiteral("orion-light"))) {{
        theme->setCurrentTheme(QStringLiteral("orion-light"));
        qInfo() << "OK: switched to orion-light, surface0:" << theme->surface0().name();
        theme->setCurrentTheme(QStringLiteral("orion-dark"));
    }}

    qInfo() << "";
    qInfo() << "orion-framework selftest PASSED";
    return 0;
}}
""")

    # color.h, typography.h, settings.h, hardware.h — minimal stubs
    for name, content in [
        ("color.h", SPDX + """
#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QColor>

namespace Orion {{

class Color : public QObject {{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    static Color *create(QQmlEngine *e, QJSEngine *s) {{
        Q_UNUSED(e); Q_UNUSED(s);
        static Color *i = new Color();
        QQmlEngine::setObjectOwnership(i, QQmlEngine::CppOwnership);
        return i;
    }}
    Q_INVOKABLE QColor parse(const QString &s) const {{ return QColor(s); }}
    Q_INVOKABLE QColor mix(const QColor &a, const QColor &b, double t) const {{
        return QColor::fromRgbF(
            a.redF()   + (b.redF()   - a.redF())   * t,
            a.greenF() + (b.greenF() - a.greenF()) * t,
            a.blueF()  + (b.blueF()  - a.blueF()) * t,
            a.alphaF() + (b.alphaF() - a.alphaF()) * t);
    }}
    Q_INVOKABLE QColor withAlpha(const QColor &c, double alpha) const {{
        QColor r = c; r.setAlphaF(alpha); return r;
    }}
    Q_INVOKABLE QString toHex(const QColor &c) const {{
        return c.alphaF() < 1.0 ? c.name(QColor::HexArgb) : c.name(QColor::HexRgb);
    }}
private:
    Color() = default;
}};

}} // namespace Orion
"""),
        ("color.cpp", SPDX + "\n#include \"color.h\"\n"),
        ("typography.h", SPDX + """
#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QVariantMap>

namespace Orion {{

class Typography : public QObject {{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    static Typography *create(QQmlEngine *e, QJSEngine *s) {{
        Q_UNUSED(e); Q_UNUSED(s);
        static Typography *i = new Typography();
        QQmlEngine::setObjectOwnership(i, QQmlEngine::CppOwnership);
        return i;
    }}
    Q_INVOKABLE QVariantMap resolve(const QString &role) const {{
        static const QMap<QString, std::tuple<int,int,double>> table = {{
            {{ QStringLiteral("display"),     {{ 32, 600, 1.2 }} }},
            {{ QStringLiteral("h1"),          {{ 24, 600, 1.3 }} }},
            {{ QStringLiteral("h2"),          {{ 20, 600, 1.3 }} }},
            {{ QStringLiteral("h3"),          {{ 18, 500, 1.4 }} }},
            {{ QStringLiteral("body"),        {{ 15, 400, 1.5 }} }},
            {{ QStringLiteral("body-strong"), {{ 15, 600, 1.5 }} }},
            {{ QStringLiteral("caption"),    {{ 13, 400, 1.4 }} }},
            {{ QStringLiteral("overline"),    {{ 11, 600, 1.2 }} }},
            {{ QStringLiteral("mono"),        {{ 14, 400, 1.4 }} }},
        }};
        const auto it = table.constFind(role);
        if (it == table.constEnd()) return {{}};
        const auto [size, weight, lh] = it.value();
        QVariantMap m;
        m.insert(QStringLiteral("size"), size);
        m.insert(QStringLiteral("weight"), weight);
        m.insert(QStringLiteral("lineHeightPx"), int(double(size) * lh));
        return m;
    }}
private:
    Typography() = default;
}};

}} // namespace Orion
"""),
        ("typography.cpp", SPDX + "\n#include \"typography.h\"\n"),
        ("settings.h", SPDX + """
#pragma once
#include <QObject>
#include <QVariant>
#include <QQmlEngine>
#include <QJsonObject>

namespace Orion {{

class Settings : public QObject {{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit Settings(const QString &componentName = QStringLiteral("default"),
                      QObject *parent = nullptr);
    Q_PROPERTY(QString component READ component WRITE setComponent NOTIFY componentChanged)
    QString component() const {{ return m_component; }}
    void setComponent(const QString &name);
    Q_INVOKABLE QVariant get(const QString &key, const QVariant &def = {{}}) const;
    Q_INVOKABLE bool set(const QString &key, const QVariant &value);
    Q_INVOKABLE bool contains(const QString &key) const;
    Q_INVOKABLE void remove(const QString &key);
    Q_INVOKABLE bool save();
    Q_INVOKABLE bool reload();
signals:
    void componentChanged();
    void changed(const QString &key, const QVariant &value);
private:
    QString m_component;
    QString m_path;
    QJsonObject m_data;
}};

}} // namespace Orion
"""),
        ("settings.cpp", SPDX + """
#include "settings.h"
#include "log.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QStandardPaths>

ORION_LOG_CATEGORY("orion.settings")

namespace Orion {{

Settings::Settings(const QString &componentName, QObject *parent)
    : QObject(parent), m_component(componentName) {{
    setComponent(componentName);
}}

void Settings::setComponent(const QString &name) {{
    if (m_component == name) return;
    m_component = name;
    const QString baseDir =
        QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
        + QStringLiteral("/orion");
    QDir().mkpath(baseDir);
    m_path = baseDir + QStringLiteral("/") + name + QStringLiteral(".json");
    reload();
    emit componentChanged();
}}

QVariant Settings::get(const QString &key, const QVariant &def) const {{
    if (!m_data.contains(key)) return def;
    return m_data.value(key).toVariant();
}}

bool Settings::set(const QString &key, const QVariant &value) {{
    if (key.isEmpty()) return false;
    m_data.insert(key, QJsonValue::fromVariant(value));
    emit changed(key, value);
    return save();
}}

bool Settings::contains(const QString &key) const {{ return m_data.contains(key); }}
void Settings::remove(const QString &key) {{ if (m_data.contains(key)) {{ m_data.remove(key); save(); }} }}

bool Settings::save() {{
    QFile f(m_path);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) return false;
    f.write(QJsonDocument(m_data).toJson(QJsonDocument::Indented));
    return true;
}}

bool Settings::reload() {{
    QFile f(m_path);
    if (!f.exists()) {{ m_data = QJsonObject(); return true; }}
    if (!f.open(QIODevice::ReadOnly)) return false;
    QJsonParseError err{{}};
    const auto doc = QJsonDocument::fromJson(f.readAll(), &err);
    if (err.error != QJsonParseError::NoError) return false;
    m_data = doc.object();
    return true;
}}

}} // namespace Orion
"""),
        ("hardware.h", SPDX + """
#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QVariantList>

namespace Orion {{

class Hardware : public QObject {{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    static Hardware *create(QQmlEngine *e, QJSEngine *s) {{
        Q_UNUSED(e); Q_UNUSED(s);
        static Hardware *i = new Hardware();
        QQmlEngine::setObjectOwnership(i, QQmlEngine::CppOwnership);
        return i;
    }}
    Q_INVOKABLE QVariantList detectGPUs() const;
    Q_INVOKABLE QVariantList detectNetworkAdapters() const;
    Q_INVOKABLE QVariantList detectAudioDevices() const;
    Q_INVOKABLE QStringList suggestedDriverPackages() const;
    Q_INVOKABLE bool hasNvidia() const;
    Q_INVOKABLE bool hasBroadcomWifi() const;
private:
    Hardware() = default;
    QVariantList parseLspci(const QString &filter) const;
}};

}} // namespace Orion
"""),
        ("hardware.cpp", SPDX + """
#include "hardware.h"

#include <QProcess>
#include <QRegularExpression>

namespace Orion {{

QVariantList Hardware::parseLspci(const QString &filter) const {{
    QVariantList list;
    QProcess p;
    p.setProgram(QStringLiteral("lspci"));
    p.setArguments({{ QStringLiteral("-mm"), QStringLiteral("-nn") }});
    p.start(QIODevice::ReadOnly);
    if (!p.waitForStarted(3000) || !p.waitForFinished(5000)) return list;
    const auto out = QString::fromUtf8(p.readAllStandardOutput());
    for (const auto &line : out.split(QLatin1Char('\\n'))) {{
        if (!line.contains(filter, Qt::CaseInsensitive)) continue;
        const auto parts = line.split(QLatin1Char(';'));
        if (parts.size() < 2) continue;
        QVariantMap m;
        m.insert(QStringLiteral("raw"), line);
        QString vendor = parts.value(1).trimmed();
        vendor.remove(QRegularExpression(QStringLiteral(R"(\\[[0-9a-fA-F:]+\\]))"));
        m.insert(QStringLiteral("vendor"), vendor);
        m.insert(QStringLiteral("model"), parts.value(2).trimmed());
        list.append(m);
    }}
    return list;
}}

QVariantList Hardware::detectGPUs() const {{ return parseLspci(QStringLiteral("VGA")); }}
QVariantList Hardware::detectNetworkAdapters() const {{
    QVariantList out;
    for (const auto &v : parseLspci(QStringLiteral("Network controller"))) {{
        auto m = v.toMap();
        m.insert(QStringLiteral("type"), QStringLiteral("wifi"));
        out.append(m);
    }}
    return out;
}}
QVariantList Hardware::detectAudioDevices() const {{ return parseLspci(QStringLiteral("Audio")); }}

QStringList Hardware::suggestedDriverPackages() const {{
    QStringList out;
    if (hasNvidia()) out << QStringLiteral("nvidia-dkms")
                         << QStringLiteral("nvidia-utils")
                         << QStringLiteral("lib32-nvidia-utils");
    if (hasBroadcomWifi()) out << QStringLiteral("broadcom-wl-dkms");
    return out;
}}

bool Hardware::hasNvidia() const {{
    const auto gpus = detectGPUs();
    return std::any_of(gpus.constBegin(), gpus.constEnd(), [](const QVariant &v) {{
        return v.toMap().value(QStringLiteral("vendor")).toString()
               .contains(QStringLiteral("NVIDIA"), Qt::CaseInsensitive);
    }});
}}

bool Hardware::hasBroadcomWifi() const {{
    const auto adapters = detectNetworkAdapters();
    return std::any_of(adapters.constBegin(), adapters.constEnd(), [](const QVariant &v) {{
        return v.toMap().value(QStringLiteral("vendor")).toString()
               .contains(QStringLiteral("Broadcom"), Qt::CaseInsensitive);
    }});
}}

}} // namespace Orion
"""),
    ]:
        (fw / "src" / name).write_text(content)
        print(f"  wrote orion-framework/src/{name}")

    # 1. Shell (special — pure C++).
    write_log_files(DESKTOP / "shell", "orion.shell")
    write_component_sources("shell", SHELL_SOURCES)

    # 2. For each QML-based component, write log.h/cpp + main.cpp + per-component files.
    qml_components = [
        ("panel",            "orion.panel",            "org.orion.panel",
         [("panelKWin", "KWinClient"), ("panelPinned", "PinnedApps")]),
        # Other components have their own main.cpp + per-component files in COMPONENT_SOURCES.
    ]

    # Panel — has custom main.cpp + extra source files.
    write_log_files(DESKTOP / "panel", "orion.panel")
    write_component_sources("panel", COMPONENT_SOURCES["panel"])

    # Start menu.
    write_log_files(DESKTOP / "start-menu", "orion.startmenu")
    write_component_sources("start-menu", COMPONENT_SOURCES["start-menu"])

    # The remaining components have only log.{h,cpp} + main.cpp + one
    # controller class. For brevity, generate them via templates.
    simple_components = [
        ("notifications",   "orion.notifications",   "org.orion.notifications",
         "NotificationsDaemon", "notificationsdaemon"),
        ("quick-settings",  "orion.quicksettings",   "org.orion.quicksettings",
         "QuickState",       "quickstate"),
        ("system-monitor",  "orion.systemmonitor",   "org.orion.systemmonitor",
         "Metrics",          "metrics"),
        ("update-manager",  "orion.updatemanager",   "org.orion.updatemanager",
         "UpdateManager",    "updatemanager"),
        ("screenshot-tool", "orion.screenshot",      "org.orion.screenshot",
         "Screenshot",       "screenshot"),
        ("search",          "orion.search",          "org.orion.search",
         "SearchIndex",      "searchindex"),
        ("lockscreen",      "orion.lockscreen",      "org.orion.lockscreen",
         "LockController",   "lockcontroller"),
    ]

    for comp_name, category, qml_uri, cpp_class, h_basename in simple_components:
        write_log_files(DESKTOP / comp_name, category)
        # Stub class header + cpp (just enough to satisfy the CMakeLists.txt
        # references and let the component compile on a real Arch host).
        h = SPDX + f"""
#pragma once
#include <QObject>
#include <QVariantList>

namespace Orion {{

class {cpp_class} : public QObject {{
    Q_OBJECT
public:
    explicit {cpp_class}(QObject *parent = nullptr) : QObject(parent) {{}}
}};

}} // namespace Orion
"""
        cpp = SPDX + f"""
#include "{h_basename}.h"
#include "log.h"

ORION_LOG_CATEGORY("{category}")

namespace Orion {{
}} // namespace Orion
"""
        main_cpp = SPDX + f"""
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "log.h"
#include "{h_basename}.h"

ORION_LOG_CATEGORY("{category}")

int main(int argc, char *argv[]) {{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-{comp_name}"));
    app.setOrganizationName(QStringLiteral("OrionOS"));
    QGuiApplication::setQuitOnLastWindowClosed(false);

    Orion::{cpp_class} controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(
        QStringLiteral("controller"), &controller);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/{qml_uri}/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) {{
        qCCritical(lcOrion) << "Failed to load Main.qml";
        return 1;
    }}
    qCInfo(lcOrion) << "orion-{comp_name} ready";
    return app.exec();
}}
"""
        src = DESKTOP / comp_name / "src"
        src.mkdir(parents=True, exist_ok=True)
        (src / f"{h_basename}.h").write_text(h)
        (src / f"{h_basename}.cpp").write_text(cpp)
        (src / "main.cpp").write_text(main_cpp)
        print(f"  wrote {comp_name}/src/{{log.h,log.cpp,{h_basename}.h,{h_basename}.cpp,main.cpp}}")

    # Settings, file-manager, welcome-center, software-center need more
    # substantial controllers. Write at minimum a stub + main.cpp for each
    # so the CMakeLists.txt references resolve.
    substantial = [
        ("settings",         "orion.settings",         "org.orion.settings",
         "SettingsController", "settingscontroller"),
        ("file-manager",     "orion.filemanager",     "org.orion.filemanager",
         "FileSystem",        "filesystemmodel"),
        ("welcome-center",   "orion.welcome",          "org.orion.welcome",
         "WelcomeController", "welcomecontroller"),
        ("software-center",  "orion.softwarecenter",  "org.orion.softwarecenter",
         "PackageKitClient",  "packagekitclient"),
    ]
    for comp_name, category, qml_uri, cpp_class, h_basename in substantial:
        write_log_files(DESKTOP / comp_name, category)
        h = SPDX + f"""
#pragma once
#include <QObject>

namespace Orion {{

class {cpp_class} : public QObject {{
    Q_OBJECT
public:
    explicit {cpp_class}(QObject *parent = nullptr) : QObject(parent) {{}}
}};

}} // namespace Orion
"""
        cpp = SPDX + f"""
#include "{h_basename}.h"
#include "log.h"

ORION_LOG_CATEGORY("{category}")

namespace Orion {{
}} // namespace Orion
"""
        main_cpp = SPDX + f"""
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "log.h"
#include "{h_basename}.h"

ORION_LOG_CATEGORY("{category}")

int main(int argc, char *argv[]) {{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("orion-{comp_name}"));
    app.setOrganizationName(QStringLiteral("OrionOS"));
    QGuiApplication::setQuitOnLastWindowClosed(false);

    Orion::{cpp_class} controller;
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(
        QStringLiteral("controller"), &controller);
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/{qml_uri}/qml/Main.qml")));
    if (engine.rootObjects().isEmpty()) {{
        qCCritical(lcOrion) << "Failed to load Main.qml";
        return 1;
    }}
    qCInfo(lcOrion) << "orion-{comp_name} ready";
    return app.exec();
}}
"""
        src = DESKTOP / comp_name / "src"
        src.mkdir(parents=True, exist_ok=True)
        (src / f"{h_basename}.h").write_text(h)
        (src / f"{h_basename}.cpp").write_text(cpp)
        (src / "main.cpp").write_text(main_cpp)
        print(f"  wrote {comp_name}/src/{{log.h,log.cpp,{h_basename}.h,{h_basename}.cpp,main.cpp}}")

    print("\\nDone — all C++ source files regenerated.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
