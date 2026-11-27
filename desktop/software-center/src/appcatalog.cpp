// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/appcatalog.cpp — Orion::AppCatalog implementation.

#include "appcatalog.h"
#include "log.h"

namespace Orion {

AppCatalog::AppCatalog(QObject *parent)
    : QObject(parent)
{
    load();
}

AppCatalog::~AppCatalog() = default;

void AppCatalog::load()
{
    // TODO: Implement Read /usr/share/applications/*.desktop and present as a categorized list; resolve icons via QIcon::fromTheme.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionSoftwareCenter) << "AppCatalog::load() — skeleton, TODO";
}

void AppCatalog::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
