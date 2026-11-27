// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/pinnedapps.cpp — pinned-apps implementation.

#include "pinnedapps.h"
#include "log.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

namespace Orion {

PinnedApps::PinnedApps(QObject *parent)
    : QObject(parent)
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                        + QStringLiteral("/orion");
    m_filePath = dir + QStringLiteral("/panel.json");
    load();
}

PinnedApps::~PinnedApps() = default;

QVariantList PinnedApps::defaultPinned() const
{
    // Sensible defaults if the user has no pinned-app config yet.
    // These map to applications that the Orion ISO ships (see
    // distro/archiso/packages.x86_64).
    return {
        QVariantMap{
            {QStringLiteral("desktopFileId"), QStringLiteral("firefox.desktop")},
            {QStringLiteral("name"),          QStringLiteral("Firefox")},
            {QStringLiteral("icon"),          QStringLiteral("firefox")},
            {QStringLiteral("exec"),          QStringLiteral("firefox")},
        },
        QVariantMap{
            {QStringLiteral("desktopFileId"), QStringLiteral("orion-file-manager.desktop")},
            {QStringLiteral("name"),          QStringLiteral("Files")},
            {QStringLiteral("icon"),          QStringLiteral("system-file-manager")},
            {QStringLiteral("exec"),          QStringLiteral("orion-file-manager")},
        },
        QVariantMap{
            {QStringLiteral("desktopFileId"), QStringLiteral("orion-settings.desktop")},
            {QStringLiteral("name"),          QStringLiteral("Settings")},
            {QStringLiteral("icon"),          QStringLiteral("preferences-system")},
            {QStringLiteral("exec"),          QStringLiteral("orion-settings")},
        },
        QVariantMap{
            {QStringLiteral("desktopFileId"), QStringLiteral("orion-terminal.desktop")},
            {QStringLiteral("name"),          QStringLiteral("Terminal")},
            {QStringLiteral("icon"),          QStringLiteral("utilities-terminal")},
            {QStringLiteral("exec"),          QStringLiteral("orion-terminal")},
        },
    };
}

void PinnedApps::load()
{
    QFile f(m_filePath);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_pinned = defaultPinned();
        qCInfo(orionPanel) << "PinnedApps: no config file at" << m_filePath
                           << "; using default pinned list";
        return;
    }
    const QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isObject()) {
        m_pinned = defaultPinned();
        qCWarning(orionPanel) << "PinnedApps: malformed JSON in" << m_filePath
                              << "; using default pinned list";
        return;
    }
    const QJsonArray arr = doc.object().value(QStringLiteral("pinned")).toArray();
    if (arr.isEmpty()) {
        m_pinned = defaultPinned();
        return;
    }
    m_pinned.clear();
    for (const QJsonValue &v : arr) {
        const QJsonObject o = v.toObject();
        m_pinned.append(QVariantMap{
            {QStringLiteral("desktopFileId"), o.value(QStringLiteral("desktopFileId")).toString()},
            {QStringLiteral("name"),          o.value(QStringLiteral("name")).toString()},
            {QStringLiteral("icon"),          o.value(QStringLiteral("icon")).toString()},
            {QStringLiteral("exec"),          o.value(QStringLiteral("exec")).toString()},
        });
    }
}

void PinnedApps::save()
{
    const QString dir = QFileInfo(m_filePath).absolutePath();
    QDir().mkpath(dir);

    QFile f(m_filePath);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qCWarning(orionPanel) << "PinnedApps: cannot write to" << m_filePath;
        return;
    }
    QJsonArray arr;
    for (const QVariant &v : std::as_const(m_pinned)) {
        arr.append(QJsonObject::fromVariantMap(v.toMap()));
    }
    const QJsonDocument doc(QJsonObject{{ QStringLiteral("pinned"), arr }});
    f.write(doc.toJson(QJsonDocument::Indented));
}

void PinnedApps::pin(const QVariantMap &entry)
{
    const QString id = entry.value(QStringLiteral("desktopFileId")).toString();
    if (id.isEmpty())
        return;
    // Avoid duplicates
    for (const QVariant &v : std::as_const(m_pinned)) {
        if (v.toMap().value(QStringLiteral("desktopFileId")).toString() == id)
            return;
    }
    m_pinned.prepend(entry);
    save();
    emit pinnedAppsChanged();
}

void PinnedApps::unpin(const QString &desktopFileId)
{
    for (int i = 0; i < m_pinned.size(); ++i) {
        if (m_pinned[i].toMap().value(QStringLiteral("desktopFileId")).toString() == desktopFileId) {
            m_pinned.removeAt(i);
            save();
            emit pinnedAppsChanged();
            return;
        }
    }
}

void PinnedApps::refresh()
{
    const QVariantList old = m_pinned;
    load();
    if (old != m_pinned)
        emit pinnedAppsChanged();
}

}  // namespace Orion
