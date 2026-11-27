// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/settings.cpp — Orion per-user JSON settings implementation.

#include "settings.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonValue>
#include <QSaveFile>
#include <QStandardPaths>

#include "log.h"

namespace Orion {

Settings::Settings(const QString &name, QObject *parent)
    : QObject(parent)
    , m_name(name)
    , m_loaded(false)
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)
                        + QStringLiteral("/orion");
    m_filePath = dir + QLatin1Char('/') + name + QStringLiteral(".json");
    load();
}

Settings::~Settings() = default;

void Settings::load()
{
    QFile f(m_filePath);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_data = QJsonObject();
        m_loaded = false;
        return;
    }
    const QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isObject()) {
        m_data = QJsonObject();
        m_loaded = false;
        qCWarning(orionFramework) << "Settings file" << m_filePath
                                   << "is not a JSON object; treating as empty.";
        return;
    }
    m_data = doc.object();
    m_loaded = true;
}

bool Settings::save()
{
    const QString dir = QFileInfo(m_filePath).absolutePath();
    QDir().mkpath(dir);

    QSaveFile out(m_filePath);
    if (!out.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qCWarning(orionFramework) << "Settings: cannot open" << m_filePath << "for writing";
        return false;
    }
    const QJsonDocument doc(m_data);
    const QByteArray payload = doc.toJson(QJsonDocument::Indented);
    if (out.write(payload) != payload.size()) {
        qCWarning(orionFramework) << "Settings: short write to" << m_filePath;
        return false;
    }
    if (!out.commit()) {
        qCWarning(orionFramework) << "Settings: commit failed for" << m_filePath;
        return false;
    }
    return true;
}

QJsonValue Settings::nestedGet(const QJsonObject &root, const QStringList &parts)
{
    QJsonValue current = root;
    for (const QString &part : parts) {
        if (!current.isObject())
            return QJsonValue();
        current = current.toObject().value(part);
        if (current.isUndefined())
            return QJsonValue();
    }
    return current;
}

void Settings::nestedSet(QJsonObject &root, const QStringList &parts, const QJsonValue &value)
{
    if (parts.isEmpty())
        return;
    if (parts.size() == 1) {
        root.insert(parts.first(), value);
        return;
    }
    QJsonObject child = root.value(parts.first()).toObject();
    nestedSet(child, parts.mid(1), value);
    root.insert(parts.first(), child);
}

QJsonObject Settings::nestedRemove(QJsonObject root, const QStringList &parts)
{
    if (parts.isEmpty())
        return root;
    if (parts.size() == 1) {
        root.remove(parts.first());
        return root;
    }
    QJsonObject child = root.value(parts.first()).toObject();
    child = nestedRemove(child, parts.mid(1));
    root.insert(parts.first(), child);
    return root;
}

QVariant Settings::get(const QString &key, const QVariant &fallback) const
{
    const QStringList parts = key.split(QLatin1Char('/'), Qt::SkipEmptyParts);
    const QJsonValue v = nestedGet(m_data, parts);
    if (v.isUndefined() || v.isNull())
        return fallback;
    return v.toVariant();
}

QString Settings::getString(const QString &key, const QString &fallback) const
{
    const QVariant v = get(key);
    return v.isValid() ? v.toString() : fallback;
}

int Settings::getInt(const QString &key, int fallback) const
{
    const QVariant v = get(key);
    bool ok = false;
    const int i = v.toInt(&ok);
    return ok ? i : fallback;
}

bool Settings::getBool(const QString &key, bool fallback) const
{
    const QVariant v = get(key);
    return v.isValid() ? v.toBool() : fallback;
}

qreal Settings::getReal(const QString &key, qreal fallback) const
{
    const QVariant v = get(key);
    bool ok = false;
    const qreal r = v.toReal(&ok);
    return ok ? r : fallback;
}

bool Settings::set(const QString &key, const QVariant &value)
{
    const QStringList parts = key.split(QLatin1Char('/'), Qt::SkipEmptyParts);
    if (parts.isEmpty()) {
        qCWarning(orionFramework) << "Settings::set: empty key";
        return false;
    }
    nestedSet(m_data, parts, QJsonValue::fromVariant(value));
    if (save()) {
        emit changed(key);
        return true;
    }
    return false;
}

bool Settings::contains(const QString &key) const
{
    const QStringList parts = key.split(QLatin1Char('/'), Qt::SkipEmptyParts);
    const QJsonValue v = nestedGet(m_data, parts);
    return !v.isUndefined();
}

bool Settings::remove(const QString &key)
{
    const QStringList parts = key.split(QLatin1Char('/'), Qt::SkipEmptyParts);
    if (parts.isEmpty() || !contains(key))
        return false;
    m_data = nestedRemove(m_data, parts);
    if (save()) {
        emit changed(key);
        return true;
    }
    return false;
}

QString Settings::filePath() const
{
    return m_filePath;
}

}  // namespace Orion
