// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/placesmodel.cpp — Orion::PlacesModel implementation.

#include "placesmodel.h"
#include "log.h"

namespace Orion {

PlacesModel::PlacesModel(QObject *parent)
    : QObject(parent)
{
    load();
}

PlacesModel::~PlacesModel() = default;

void PlacesModel::load()
{
    // TODO: Implement XDG user dirs (Documents, Pictures, ...), recent files, removable volumes; static list with refresh().
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionFileManager) << "PlacesModel::load() — skeleton, TODO";
}

void PlacesModel::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
