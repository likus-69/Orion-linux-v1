// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/settings.h — Orion per-user JSON settings reader/writer.
//
// A small convenience wrapper around QFile + QJsonDocument that reads and
// writes ~/.config/orion/<name>.json. Each instance is bound to a single
// file (the `name` passed to the constructor) and caches the parsed JSON
// in memory for cheap `get()` calls.
//
// Writing is atomic: the document is serialized via QSaveFile (temp file +
// rename) in the same directory. The XDG config dir is created lazily on
// first write.

#pragma once

#include <QObject>
#include <QVariant>
#include <QString>
#include <QJsonObject>

namespace Orion {

class Settings : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(OrionSettings)

public:
    explicit Settings(const QString &name, QObject *parent = nullptr);
    ~Settings() override;

    /// Returns the value for `key`, or `fallback` if the key is absent.
    /// Supports nested keys via '/' (e.g. `get("ui/panel/height", 48)`).
    Q_INVOKABLE QVariant get(const QString &key, const QVariant &fallback = {}) const;
    Q_INVOKABLE QString getString(const QString &key, const QString &fallback = {}) const;
    Q_INVOKABLE int getInt(const QString &key, int fallback = 0) const;
    Q_INVOKABLE bool getBool(const QString &key, bool fallback = false) const;
    Q_INVOKABLE qreal getReal(const QString &key, qreal fallback = 0.0) const;

    /// Sets `key` to `value` and persists atomically. Returns true on success.
    Q_INVOKABLE bool set(const QString &key, const QVariant &value);

    Q_INVOKABLE bool contains(const QString &key) const;
    Q_INVOKABLE bool remove(const QString &key);
    Q_INVOKABLE QString filePath() const;

signals:
    void changed(const QString &key);

private:
    void load();
    bool save();
    static QJsonValue nestedGet(const QJsonObject &root, const QStringList &parts);
    static void nestedSet(QJsonObject &root, const QStringList &parts, const QJsonValue &value);
    static QJsonObject nestedRemove(QJsonObject root, const QStringList &parts);

    QString m_name;
    QString m_filePath;
    QJsonObject m_data;
    bool m_loaded;
};

}  // namespace Orion
