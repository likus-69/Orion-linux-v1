// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/screenshot.cpp — Orion::Screenshot implementation.

#include "screenshot.h"
#include "log.h"

namespace Orion {

Screenshot::Screenshot(QObject *parent)
    : QObject(parent)
{
    load();
}

Screenshot::~Screenshot() = default;

void Screenshot::load()
{
    // TODO: Implement Qt6 QScreen::grabWindow() for single-screen; xdg-desktop-portal Screenshot interface for region capture.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionScreenshot) << "Screenshot::load() — skeleton, TODO";
}

void Screenshot::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
