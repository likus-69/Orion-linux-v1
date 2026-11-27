// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/appindex.cpp — Orion::AppIndex implementation.

#include "appindex.h"
#include "log.h"

namespace Orion {

AppIndex::AppIndex(QObject *parent)
    : QObject(parent)
{
    load();
}

AppIndex::~AppIndex() = default;

void AppIndex::load()
{
    // TODO: Implement Read applications.menu (XDG menu spec); provide allApps, pinnedApps, recentlyUsed lists.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionStartMenu) << "AppIndex::load() — skeleton, TODO";
}

void AppIndex::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
