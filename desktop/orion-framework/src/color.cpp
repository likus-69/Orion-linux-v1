// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/color.cpp — color manipulation implementation.

#include "color.h"

#include <QtMath>

namespace Orion {

QColor Color::mix(const QColor &a, const QColor &b, qreal t)
{
    t = qBound(0.0, t, 1.0);
    return QColor(
        qRound(a.red()   * (1.0 - t) + b.red()   * t),
        qRound(a.green() * (1.0 - t) + b.green() * t),
        qRound(a.blue()  * (1.0 - t) + b.blue()  * t),
        qRound(a.alpha() * (1.0 - t) + b.alpha() * t)
    );
}

QColor Color::withAlpha(const QColor &c, qreal alpha)
{
    QColor out = c;
    out.setAlphaF(qBound(0.0, alpha, 1.0));
    return out;
}

QColor Color::lighten(const QColor &c, qreal factor)
{
    factor = qBound(0.0, factor, 2.0);
    if (factor <= 1.0)
        return c;
    qreal h, s, l, a;
    c.getHslF(&h, &s, &l, &a);
    l = qBound(0.0, l + (1.0 - l) * (factor - 1.0), 1.0);
    QColor out;
    out.setHslF(h, s, l, a);
    return out;
}

QColor Color::darken(const QColor &c, qreal factor)
{
    factor = qBound(0.0, factor, 2.0);
    if (factor >= 1.0)
        return c;
    qreal h, s, l, a;
    c.getHslF(&h, &s, &l, &a);
    l = qBound(0.0, l * factor, 1.0);
    QColor out;
    out.setHslF(h, s, l, a);
    return out;
}

QColor Color::desaturate(const QColor &c, qreal factor)
{
    factor = qBound(0.0, factor, 1.0);
    qreal h, s, l, a;
    c.getHslF(&h, &s, &l, &a);
    s = qBound(0.0, s * (1.0 - factor), 1.0);
    QColor out;
    out.setHslF(h, s, l, a);
    return out;
}

bool Color::isDark(const QColor &c)
{
    // Perceived luminance per WCAG luminance formula.
    const auto channel = [](int v) -> qreal {
        const qreal vs = v / 255.0;
        return vs <= 0.03928 ? vs / 12.92 : qPow((vs + 0.055) / 1.055, 2.4);
    };
    const qreal luma = 0.2126 * channel(c.red())
                     + 0.7152 * channel(c.green())
                     + 0.0722 * channel(c.blue());
    return luma < 0.5;
}

qreal Color::contrastRatio(const QColor &a, const QColor &b)
{
    const auto channel = [](int v) -> qreal {
        const qreal vs = v / 255.0;
        return vs <= 0.03928 ? vs / 12.92 : qPow((vs + 0.055) / 1.055, 2.4);
    };
    const auto luma = [&channel](const QColor &c) -> qreal {
        return 0.2126 * channel(c.red())
             + 0.7152 * channel(c.green())
             + 0.0722 * channel(c.blue()) + 0.05;
    };
    const qreal l1 = luma(a);
    const qreal l2 = luma(b);
    const qreal lighter = qMax(l1, l2);
    const qreal darker   = qMin(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
}

}  // namespace Orion
