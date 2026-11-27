// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/mountsmodel.cpp — Orion::MountsModel implementation.

#include "mountsmodel.h"
#include "log.h"

namespace Orion {

MountsModel::MountsModel(QObject *parent)
    : QObject(parent)
{
    load();
}

MountsModel::~MountsModel() = default;

void MountsModel::load()
{
    // TODO: Implement Read /proc/mounts and udisks2 D-Bus for removable media; emit mountsChanged on mount/unmount events.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionFileManager) << "MountsModel::load() — skeleton, TODO";
}

void MountsModel::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
