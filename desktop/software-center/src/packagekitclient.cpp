// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/packagekitclient.cpp — Orion::PackageKitClient implementation.

#include "packagekitclient.h"
#include "log.h"

namespace Orion {

PackageKitClient::PackageKitClient(QObject *parent)
    : QObject(parent)
{
    load();
}

PackageKitClient::~PackageKitClient() = default;

void PackageKitClient::load()
{
    // TODO: Implement PackageKit D-Bus at org.freedesktop.PackageKit: GetPackages, InstallPackage, RemovePackage, GetUpdates.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionSoftwareCenter) << "PackageKitClient::load() — skeleton, TODO";
}

void PackageKitClient::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
