// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/about.h — Orion OS metadata.
//
// Reads /etc/os-release at construction and exposes the values as QML
// properties. Used by the Welcome Center and the `orion-about` helper
// script's GUI variant (when it exists).

#pragma once

#include <QObject>
#include <QString>

namespace Orion {

class About : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(OrionAbout)

    Q_PROPERTY(QString name        READ name        CONSTANT)
    Q_PROPERTY(QString version     READ version     CONSTANT)
    Q_PROPERTY(QString prettyName  READ prettyName  CONSTANT)
    Q_PROPERTY(QString homeUrl     READ homeUrl     CONSTANT)
    Q_PROPERTY(QString supportUrl  READ supportUrl  CONSTANT)
    Q_PROPERTY(QString bugReportUrl READ bugReportUrl CONSTANT)
    Q_PROPERTY(QString buildId     READ buildId     CONSTANT)
    Q_PROPERTY(QString architecture READ architecture CONSTANT)
    Q_PROPERTY(QString kernel      READ kernel      CONSTANT)

public:
    explicit About(QObject *parent = nullptr);

    QString name()         const { return m_name; }
    QString version()      const { return m_version; }
    QString prettyName()   const { return m_prettyName; }
    QString homeUrl()      const { return m_homeUrl; }
    QString supportUrl()   const { return m_supportUrl; }
    QString bugReportUrl() const { return m_bugReportUrl; }
    QString buildId()      const { return m_buildId; }
    QString architecture() const { return m_architecture; }
    QString kernel()       const { return m_kernel; }

private:
    void load();

    QString m_name;
    QString m_version;
    QString m_prettyName;
    QString m_homeUrl;
    QString m_supportUrl;
    QString m_bugReportUrl;
    QString m_buildId;
    QString m_architecture;
    QString m_kernel;
};

}  // namespace Orion
