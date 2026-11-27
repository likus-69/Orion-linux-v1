// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/hardware.cpp — lightweight hardware detection implementation.

#include "hardware.h"

#include <QDir>
#include <QFile>
#include <QHostInfo>
#include <QRegularExpression>
#include <QSysInfo>
#include <QTextStream>
#include <QThread>

namespace Orion {

namespace {
QString readFirstLine(const QString &path)
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();
    return QString::fromUtf8(f.readLine()).trimmed();
}

QString parseCpuModel()
{
    QFile f(QStringLiteral("/proc/cpuinfo"));
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
        return QSysInfo::prettyProductName();
    QString model;
    while (!f.atEnd()) {
        const QString line = QString::fromUtf8(f.readLine());
        if (line.startsWith(QStringLiteral("model name"))) {
            const int eq = line.indexOf(QLatin1Char(':'));
            if (eq >= 0)
                model = line.mid(eq + 1).trimmed();
            break;
        }
    }
    return model.isEmpty() ? QStringLiteral("unknown CPU") : model;
}

qint64 parseMemTotalKiB()
{
    QFile f(QStringLiteral("/proc/meminfo"));
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
        return 0;
    while (!f.atEnd()) {
        const QString line = QString::fromUtf8(f.readLine());
        if (line.startsWith(QStringLiteral("MemTotal:"))) {
            const QStringList parts = line.split(QRegularExpression(QStringLiteral("\\s+")),
                                                 Qt::SkipEmptyParts);
            if (parts.size() >= 2)
                return parts.at(1).toLongLong();
        }
    }
    return 0;
}

bool detectBattery()
{
    QDir syspower(QStringLiteral("/sys/class/power_supply"));
    if (!syspower.exists())
        return false;
    const QStringList entries = syspower.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    for (const QString &entry : entries) {
        QFile type(syspower.absoluteFilePath(entry + QStringLiteral("/type")));
        if (!type.open(QIODevice::ReadOnly | QIODevice::Text))
            continue;
        if (QString::fromUtf8(type.readLine()).trimmed() == QStringLiteral("Battery"))
            return true;
    }
    return false;
}
}  // namespace

Hardware::Hardware(QObject *parent)
    : QObject(parent)
    , m_cpuCores(0)
    , m_totalMemoryKiB(0)
    , m_hasBattery(false)
{
    load();
}

void Hardware::load()
{
    m_cpuModel       = parseCpuModel();
    m_cpuCores       = QThread::idealThreadCount();
    m_architecture   = QSysInfo::currentCpuArchitecture();
    m_totalMemoryKiB = parseMemTotalKiB();
    m_kernelVersion  = QSysInfo::kernelVersion();
    m_machineHostName = QHostInfo::localHostName();
    m_product        = QSysInfo::machineProductName();
    m_vendor         = QSysInfo::machineVendor();
    m_hasBattery     = detectBattery();
}

QString Hardware::summary() const
{
    QString out;
    QTextStream s(&out);
    s << "OS: " << QSysInfo::prettyProductName() << '\n';
    s << "Kernel: " << m_kernelVersion << '\n';
    s << "Architecture: " << m_architecture << '\n';
    s << "CPU: " << m_cpuModel << " (" << m_cpuCores << " cores)\n";
    s << "Memory: " << m_totalMemoryKiB / 1024 << " MiB ("
      << m_totalMemoryKiB / (1024 * 1024) << " GiB)\n";
    s << "Host: " << m_machineHostName << '\n';
    s << "Product: " << m_vendor << ' ' << m_product << '\n';
    s << "Battery: " << (m_hasBattery ? "present" : "absent") << '\n';
    return out;
}

}  // namespace Orion
