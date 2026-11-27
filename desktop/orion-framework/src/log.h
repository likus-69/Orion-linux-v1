// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/log.h — Orion logging helpers.
//
// Provides:
//   - The `orionFramework` QLoggingCategory for filtering Orion framework logs.
//   - Orion::Log — a small static helper class for installing a structured
//     message handler and convenient categorized logging.

#pragma once

#include <QLoggingCategory>
#include <QString>

QT_BEGIN_NAMESPACE
Q_DECLARE_LOGGING_CATEGORY(orionFramework)
QT_END_NAMESPACE

namespace Orion {
namespace Log {

/// Installs a Qt message handler that writes structured logs to stderr
/// (colorized when attached to a tty) or to journald when available.
/// Idempotent: safe to call from every component's main(); only the first
/// call installs the handler.
void installHandler();

/// Returns the Orion OS version string (read from /etc/os-release at first
/// call, then cached). Used by the message handler for context.
QString orionVersion();

/// Returns the build-time framework version (PROJECT_VERSION from CMake).
QString frameworkVersion();

}  // namespace Log
}  // namespace Orion
