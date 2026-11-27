// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/pinnedapps.h — pinned-apps model for the Orion Panel.
//
// Loads the user's pinned-app list from ~/.config/orion/panel.json and
// exposes it to QML as the `pinnedApps` property. Each entry is a
// QVariantMap with the keys that panel/qml/Main.qml expects:
//   - desktopFileId (QString) — e.g. "firefox.desktop"
//   - name          (QString) — display name
//   - icon          (QString) — icon name (matches a freedesktop icon theme entry)
//   - exec          (QString) — Exec= line from the .desktop file
//
// The on-disk JSON format is:
//   { "pinned": [ {"desktopFileId": "...", "name": "...", "icon": "...", "exec": "..."}, ... ] }
//
// If the file is missing or malformed, a sensible default pinned list is
// used (browser, file manager, settings, terminal).

#pragma once

#include <QObject>
#include <QVariantList>
#include <QString>

namespace Orion {

class Settings;

class PinnedApps : public QObject
{
    Q_OBJECT

    /// The current pinned-app list. QML reads this via the `panelPinned.pinnedApps`
    /// context property.
    Q_PROPERTY(QVariantList pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)

public:
    explicit PinnedApps(QObject *parent = nullptr);
    ~PinnedApps() override;

    QVariantList pinnedApps() const { return m_pinned; }

    /// Adds `entry` to the front of the pinned list and persists.
    /// `entry` must contain at least desktopFileId; missing keys default
    /// to empty strings.
    Q_INVOKABLE void pin(const QVariantMap &entry);

    /// Removes the first pinned entry whose `desktopFileId` matches `id`.
    /// Persists the change.
    Q_INVOKABLE void unpin(const QString &desktopFileId);

    /// Re-reads the JSON file and emits pinnedAppsChanged if the list changed.
    Q_INVOKABLE void refresh();

signals:
    void pinnedAppsChanged();

private:
    void load();
    void save();
    QVariantList defaultPinned() const;

    QVariantList m_pinned;
    QString m_filePath;
};

}  // namespace Orion
