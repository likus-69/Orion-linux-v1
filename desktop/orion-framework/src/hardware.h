// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/hardware.h — lightweight hardware detection.
//
// Exposes basic hardware facts (CPU, memory, GPU, battery presence) to QML
// via the `OrionHardware` element. Used by the Welcome Center's "Hardware
// check" step and the `orion-hardware-scan` helper's GUI variant.
//
// This is intentionally a thin wrapper over QSysInfo and /proc — heavy
// hardware probing should be done by `dmidecode`, `lshw`, `inxi` which are
// shipped in the ISO as separate tools.

#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

namespace Orion {

class Hardware : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(OrionHardware)

    Q_PROPERTY(QString cpuModel       READ cpuModel       CONSTANT)
    Q_PROPERTY(int     cpuCores       READ cpuCores       CONSTANT)
    Q_PROPERTY(QString architecture   READ architecture   CONSTANT)
    Q_PROPERTY(qint64  totalMemoryKiB READ totalMemoryKiB CONSTANT)
    Q_PROPERTY(qint64  totalMemoryGB  READ totalMemoryGB  CONSTANT)
    Q_PROPERTY(QString kernelVersion  READ kernelVersion  CONSTANT)
    Q_PROPERTY(QString machineHostName READ machineHostName CONSTANT)
    Q_PROPERTY(QString product        READ product        CONSTANT)
    Q_PROPERTY(QString vendor         READ vendor         CONSTANT)
    Q_PROPERTY(bool    hasBattery     READ hasBattery     CONSTANT)

public:
    explicit Hardware(QObject *parent = nullptr);

    QString cpuModel()       const { return m_cpuModel; }
    int     cpuCores()       const { return m_cpuCores; }
    QString architecture()   const { return m_architecture; }
    qint64  totalMemoryKiB() const { return m_totalMemoryKiB; }
    qint64  totalMemoryGB()  const { return m_totalMemoryKiB / (1024 * 1024); }
    QString kernelVersion()  const { return m_kernelVersion; }
    QString machineHostName() const { return m_machineHostName; }
    QString product()        const { return m_product; }
    QString vendor()         const { return m_vendor; }
    bool    hasBattery()     const { return m_hasBattery; }

    /// Returns a multi-line plain-text summary suitable for the
    /// `orion-hardware-scan` helper script. Each line is "key: value".
    Q_INVOKABLE QString summary() const;

private:
    void load();

    QString m_cpuModel;
    int     m_cpuCores;
    QString m_architecture;
    qint64  m_totalMemoryKiB;
    QString m_kernelVersion;
    QString m_machineHostName;
    QString m_product;
    QString m_vendor;
    bool    m_hasBattery;
};

}  // namespace Orion
