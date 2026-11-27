// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/sessionbus.h — Orion Shell session-bus registration.
//
// The Orion Shell acquires the `org.orion.Shell` well-known name on the
// session bus so other Orion components (panel, start-menu, etc.) can
// detect that the shell is running, and exposes a tiny D-Bus interface
// for cross-component queries like "is the session locked?".

#pragma once

#include <QObject>

namespace Orion {

class SessionBus : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.orion.Shell")

    Q_PROPERTY(bool locked READ locked NOTIFY lockedChanged)

public:
    explicit SessionBus(QObject *parent = nullptr);
    ~SessionBus() override;

    /// Attempts to acquire `org.orion.Shell` on the session bus. Returns
    /// true if the name was acquired (i.e., no other Orion Shell instance
    /// is already running in this session).
    bool acquireName();

    bool locked() const { return m_locked; }

public slots:
    /// D-Bus method: lock the session (invoked by the lockscreen component
    /// once it has rendered the lock surface).
    void setLocked(bool on);

signals:
    void lockedChanged();

private:
    bool m_locked;
};

}  // namespace Orion
