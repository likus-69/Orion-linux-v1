// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/metrics.cpp — Orion::Metrics implementation.

#include "metrics.h"
#include "log.h"

namespace Orion {

Metrics::Metrics(QObject *parent)
    : QObject(parent)
{
    load();
}

Metrics::~Metrics() = default;

void Metrics::load()
{
    // TODO: Implement QTimer-driven polling of /proc/stat (CPU), /proc/meminfo (memory), /proc/net/dev (network); expose as numeric properties.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionSystemMonitor) << "Metrics::load() — skeleton, TODO";
}

void Metrics::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
