// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// qml/Theme.qml — convenience alias for the C++ Theme singleton.
// Components can do: import org.orion.framework 1.0; then use Theme.accent500
// directly (no extra binding needed).

pragma Singleton
import QtQuick

import org.orion.framework

QtObject {
    // This file exists primarily as documentation. The real Theme singleton
    // is registered from C++ (src/theme.cpp). QML code accesses it as `Theme`
    // after `import org.orion.framework`.
    //
    // See src/theme.h for the full property list.
}
