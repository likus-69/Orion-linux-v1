// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/about.cpp — Orion OS metadata implementation.

#include "about.h"

#include <QFile>
#include <QSysInfo>
#include <QRegularExpression>

namespace Orion {

namespace {
QString readOsRelease(const QString &key)
{
    static const QStringList files = {
        QStringLiteral("/etc/os-release"),
        QStringLiteral("/usr/lib/os-release"),
    };
    for (const QString &path : files) {
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
            continue;
        while (!f.atEnd()) {
            const QString line = QString::fromUtf8(f.readLine()).trimmed();
            if (line.startsWith(key + QLatin1Char('='))) {
                QString v = line.mid(key.length() + 1);
                if (v.startsWith(QLatin1Char('"')) && v.endsWith(QLatin1Char('"')))
                    v = v.mid(1, v.length() - 2);
                return v;
            }
        }
    }
    return QString();
}
}  // namespace

About::About(QObject *parent)
    : QObject(parent)
{
    load();
}

void About::load()
{
    m_name         = readOsRelease(QStringLiteral("NAME"));
    m_version      = readOsRelease(QStringLiteral("VERSION_ID"));
    m_prettyName   = readOsRelease(QStringLiteral("PRETTY_NAME"));
    m_homeUrl      = readOsRelease(QStringLiteral("HOME_URL"));
    m_supportUrl   = readOsRelease(QStringLiteral("SUPPORT_URL"));
    m_bugReportUrl = readOsRelease(QStringLiteral("BUG_REPORT_URL"));
    m_buildId      = readOsRelease(QStringLiteral("BUILD_ID"));

    if (m_name.isEmpty())
        m_name = QStringLiteral("Orion OS");
    if (m_version.isEmpty())
        m_version = QStringLiteral("unknown");
    if (m_prettyName.isEmpty())
        m_prettyName = m_name + QStringLiteral(" ") + m_version;

    m_architecture = QSysInfo::currentCpuArchitecture();
    m_kernel       = QSysInfo::kernelVersion();
}

}  // namespace Orion
