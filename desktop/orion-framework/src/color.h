// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/color.h — color manipulation helpers.
//
// Static utility methods for blending, mixing, and converting colors.
// Exposed as a QML element `OrionColor` so QML code can call e.g.
// `OrionColor.mix(c1, c2, 0.5)` or `OrionColor.withAlpha(c, 0.4)`.

#pragma once

#include <QObject>
#include <QColor>

namespace Orion {

class Color : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(OrionColor)

public:
    explicit Color(QObject *parent = nullptr) : QObject(parent) {}

    /// Linear interpolation between two colors. `t=0` returns `a`, `t=1`
    /// returns `b`. Alpha is interpolated as well.
    Q_INVOKABLE static QColor mix(const QColor &a, const QColor &b, qreal t);

    /// Returns `c` with the alpha channel replaced by `alpha` (0..1).
    Q_INVOKABLE static QColor withAlpha(const QColor &c, qreal alpha);

    /// Returns `c` lightened by `factor` (1.0 = no change, 1.5 = +50% lightness).
    Q_INVOKABLE static QColor lighten(const QColor &c, qreal factor);

    /// Returns `c` darkened by `factor` (1.0 = no change, 0.5 = -50% lightness).
    Q_INVOKABLE static QColor darken(const QColor &c, qreal factor);

    /// Returns `c` desaturated by `factor` (0 = full saturation, 1 = gray).
    Q_INVOKABLE static QColor desaturate(const QColor &c, qreal factor);

    /// Returns true if `c` is "dark" (perceived luminance < 0.5).
    Q_INVOKABLE static bool isDark(const QColor &c);

    /// Returns the contrast ratio between two colors per WCAG 2.1.
    /// Range: 1.0 (identical) to 21.0 (black vs white).
    Q_INVOKABLE static qreal contrastRatio(const QColor &a, const QColor &b);
};

}  // namespace Orion
