// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/typography.h — typography access.
//
// Exposes font family names and type-scale presets as a QML element
// `OrionTypography`. Used by the framework's QML primitives (OrionLabel,
// OrionButton, etc.) to keep font choices centralized.

#pragma once

#include <QObject>
#include <QString>
#include <QFont>

namespace Orion {

class Typography : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(OrionTypography)

    Q_PROPERTY(QString fontFamily READ fontFamily CONSTANT)
    Q_PROPERTY(QString fontFamilyMono READ fontFamilyMono CONSTANT)
    Q_PROPERTY(QString fontFamilyCjk READ fontFamilyCjk CONSTANT)

public:
    explicit Typography(QObject *parent = nullptr) : QObject(parent) {}

    QString fontFamily() const     { return QStringLiteral("Inter"); }
    QString fontFamilyMono() const { return QStringLiteral("JetBrains Mono"); }
    QString fontFamilyCjk() const  { return QStringLiteral("Noto Sans CJK SC"); }

    /// Returns a QFont preconfigured for the named type-scale preset
    /// ("display", "h1", "h2", "h3", "body", "body-strong", "caption",
    /// "overline", "mono"). Returns the body font if `preset` is unknown.
    Q_INVOKABLE QFont fontFor(const QString &preset) const;
};

}  // namespace Orion
