// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/placesmodel.h — Orion::PlacesModel for orion-file-manager.
//
// Skeleton: exposes the Q_PROPERTY surface that orion-file-manager's QML
// expects. The deep integration logic (XDG user dirs (Documents, Pictures, ...), recent files, removable volumes; static list with refresh())
// is marked with TODOs in the .cpp file. The skeleton compiles and links
// against Qt6; running it produces an empty/default model until the TODOs
// are implemented (CONTRIBUTING.md §23 rule 18 — degrade gracefully).

#pragma once

#include <QObject>
#include <QVariantList>
#include <QString>

namespace Orion {

class PlacesModel : public QObject
{
    Q_OBJECT

public:
    explicit PlacesModel(QObject *parent = nullptr);
    ~PlacesModel() override;

    // TODO: add Q_PROPERTY declarations matching what file-manager/qml/Main.qml
    // reads via the `places.<name>` context property. Example:
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
