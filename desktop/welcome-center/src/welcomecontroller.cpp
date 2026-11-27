// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/welcomecontroller.cpp — Orion::WelcomeController implementation.

#include "welcomecontroller.h"
#include "log.h"

namespace Orion {

WelcomeController::WelcomeController(QObject *parent)
    : QObject(parent)
{
    load();
}

WelcomeController::~WelcomeController() = default;

void WelcomeController::load()
{
    // TODO: Implement First-run wizard state machine; reads/persists step state to ~/.config/orion/welcome.json.
    //
    // The skeleton returns immediately with no data loaded. QML bindings
    // against this controller's properties see default-constructed values
    // (empty lists, false bools, empty strings) until this is implemented.
    qCDebug(orionWelcomeCenter) << "WelcomeController::load() — skeleton, TODO";
}

void WelcomeController::refresh()
{
    load();
    emit dataChanged();
}

}  // namespace Orion
