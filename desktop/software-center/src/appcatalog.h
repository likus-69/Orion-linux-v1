// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/appcatalog.h — Orion::AppCatalog for orion-software-center.
//
// Skeleton: exposes the Q_PROPERTY surface that orion-software-center's QML
// expects. The deep integration logic (Read /usr/share/applications/*.desktop and present as a categorized list; resolve icons via QIcon::fromTheme)
// is marked with TODOs in the .cpp file. The skeleton compiles and links
// against Qt6; running it produces an empty/default model until the TODOs
// are implemented (CONTRIBUTING.md §23 rule 18 — degrade gracefully).

#pragma once

#include <QObject>
#include <QVariantList>
#include <QString>

namespace Orion {

class AppCatalog : public QObject
{
    Q_OBJECT

public:
    explicit AppCatalog(QObject *parent = nullptr);
    ~AppCatalog() override;

    // TODO: add Q_PROPERTY declarations matching what software-center/qml/Main.qml
    // reads via the `catalog.<name>` context property. Example:
    //   Q_PROPERTY(bool locked READ locked NOTIFY lockedChanged)
    //   bool locked() const { return m_locked; }
    // signals: void lockedChanged();
    // private: bool m_locked = false;

    /// Refresh the controller's data from its underlying source (D-Bus,
    /// /proc, JSON file, etc.). Safe to call from a QTimer.
    Q_INVOKABLE void refresh();

signals:
    /// Emitted whenever the controller's data changes. Connect this to
    /// the NOTIFY signals of the Q_PROPERTY declarations above.
    void dataChanged();

private:
    void load();
};

}  // namespace Orion
