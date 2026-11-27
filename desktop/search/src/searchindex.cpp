// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/searchindex.cpp — Orion::SearchIndex implementation.

#include "searchindex.h"
#include "log.h"

namespace Orion {

SearchIndex::SearchIndex(QObject *parent)
    : QObject(parent)
{
    load();
}

SearchIndex::~SearchIndex() = default;

void SearchIndex::load()
{
    // TODO: Implement Walk /usr/share/applications for .desktop files; query tracker3 or recently-used.xbel for files.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionSearch) << "SearchIndex::load() — skeleton, TODO";
}

void SearchIndex::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
