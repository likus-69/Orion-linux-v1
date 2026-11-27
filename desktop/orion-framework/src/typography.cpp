// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/typography.cpp — typography implementation.

#include "typography.h"

namespace Orion {

QFont Typography::fontFor(const QString &preset) const
{
    QFont f(fontFamily());
    // Match tokens.json typography.scale entries.
    if (preset == QStringLiteral("display")) {
        f.setPointSize(32); f.setWeight(QFont::DemiBold);
    } else if (preset == QStringLiteral("h1")) {
        f.setPointSize(24); f.setWeight(QFont::DemiBold);
    } else if (preset == QStringLiteral("h2")) {
        f.setPointSize(20); f.setWeight(QFont::DemiBold);
    } else if (preset == QStringLiteral("h3")) {
        f.setPointSize(18); f.setWeight(QFont::Medium);
    } else if (preset == QStringLiteral("body-strong")) {
        f.setPointSize(15); f.setWeight(QFont::DemiBold);
    } else if (preset == QStringLiteral("caption")) {
        f.setPointSize(13); f.setWeight(QFont::Normal);
    } else if (preset == QStringLiteral("overline")) {
        f.setPointSize(11); f.setWeight(QFont::DemiBold);
        f.setLetterSpacing(QFont::AbsoluteSpacing, 0.6);
    } else if (preset == QStringLiteral("mono")) {
        f.setFamily(fontFamilyMono());
        f.setPointSize(14); f.setWeight(QFont::Normal);
    } else {  // "body" and unknown
        f.setPointSize(15); f.setWeight(QFont::Normal);
    }
    return f;
}

}  // namespace Orion
