// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/filesystemmodel.cpp — Orion::FileSystemModel implementation.

#include "filesystemmodel.h"
#include "log.h"

namespace Orion {

FileSystemModel::FileSystemModel(QObject *parent)
    : QObject(parent)
{
    load();
}

FileSystemModel::~FileSystemModel() = default;

void FileSystemModel::load()
{
    // TODO: Implement QFileSystemModel wrapper exposing rows as QVariantList; supports list/icon views, sorting, hidden-file toggle.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionFileManager) << "FileSystemModel::load() — skeleton, TODO";
}

void FileSystemModel::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
