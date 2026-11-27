// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/theme.h — the Orion Theme QML singleton.
//
// Registered as `Theme` in the `org.orion.framework` QML module via
// QML_SINGLETON + QML_NAMED_ELEMENT. Exposes every design-token property
// that consumer QML files reference:
//   - 18 color properties (surface0..4, fg*, accent*, semantic*, border*)
//   - 6 spacing properties (space1..6)
//   - 5 radius properties (radiusSm/Md/Lg/Xl/Full)
//   - 3 motion properties (motionDefault/Fast/Slow)
//   - 2 typography properties (fontFamily, fontFamilyMono)
//   - 3 state properties (currentTheme, reduceMotion, reduceTransparency)
//
// Theme is a thin QML-facing wrapper around `Orion::Tokens::instance()`,
// which owns the actual token state, persistence, and change signals.
// Theme forwards Tokens's signals so QML bindings re-evaluate on theme
// switches or accessibility-toggle changes.

#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QColor>

namespace Orion {

class Theme : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_NAMED_ELEMENT(Theme)

    // --- Color properties (change when currentTheme changes) ---------------
    Q_PROPERTY(QColor surface0       READ surface0       NOTIFY themeChanged)
    Q_PROPERTY(QColor surface1       READ surface1       NOTIFY themeChanged)
    Q_PROPERTY(QColor surface2       READ surface2       NOTIFY themeChanged)
    Q_PROPERTY(QColor surface3       READ surface3       NOTIFY themeChanged)
    Q_PROPERTY(QColor surface4       READ surface4       NOTIFY themeChanged)
    Q_PROPERTY(QColor fgPrimary      READ fgPrimary      NOTIFY themeChanged)
    Q_PROPERTY(QColor fgSecondary    READ fgSecondary    NOTIFY themeChanged)
    Q_PROPERTY(QColor fgTertiary     READ fgTertiary     NOTIFY themeChanged)
    Q_PROPERTY(QColor fgDisabled     READ fgDisabled     NOTIFY themeChanged)
    Q_PROPERTY(QColor fgInverse      READ fgInverse      NOTIFY themeChanged)
    Q_PROPERTY(QColor accent300      READ accent300      NOTIFY themeChanged)
    Q_PROPERTY(QColor accent500      READ accent500      NOTIFY themeChanged)
    Q_PROPERTY(QColor accent700      READ accent700      NOTIFY themeChanged)
    Q_PROPERTY(QColor accent900      READ accent900      NOTIFY themeChanged)
    Q_PROPERTY(QColor success        READ success        NOTIFY themeChanged)
    Q_PROPERTY(QColor warning        READ warning        NOTIFY themeChanged)
    Q_PROPERTY(QColor danger         READ danger         NOTIFY themeChanged)
    Q_PROPERTY(QColor borderSubtle   READ borderSubtle   NOTIFY themeChanged)
    Q_PROPERTY(QColor borderDefault  READ borderDefault  NOTIFY themeChanged)

    // --- Spacing (constant) --------------------------------------------------
    Q_PROPERTY(int space1 READ space1 CONSTANT)
    Q_PROPERTY(int space2 READ space2 CONSTANT)
    Q_PROPERTY(int space3 READ space3 CONSTANT)
    Q_PROPERTY(int space4 READ space4 CONSTANT)
    Q_PROPERTY(int space5 READ space5 CONSTANT)
    Q_PROPERTY(int space6 READ space6 CONSTANT)

    // --- Radius (constant) ---------------------------------------------------
    Q_PROPERTY(int radiusSm   READ radiusSm   CONSTANT)
    Q_PROPERTY(int radiusMd   READ radiusMd   CONSTANT)
    Q_PROPERTY(int radiusLg   READ radiusLg   CONSTANT)
    Q_PROPERTY(int radiusXl   READ radiusXl   CONSTANT)
    Q_PROPERTY(int radiusFull READ radiusFull CONSTANT)

    // --- Motion (respects reduceMotion) -------------------------------------
    Q_PROPERTY(int motionDefault READ motionDefault NOTIFY motionChanged)
    Q_PROPERTY(int motionFast    READ motionFast    NOTIFY motionChanged)
    Q_PROPERTY(int motionSlow    READ motionSlow    NOTIFY motionChanged)

    // --- Typography (constant) -----------------------------------------------
    Q_PROPERTY(QString fontFamily     READ fontFamily     CONSTANT)
    Q_PROPERTY(QString fontFamilyMono READ fontFamilyMono CONSTANT)

    // --- State ---------------------------------------------------------------
    Q_PROPERTY(QString currentTheme       READ currentTheme       WRITE setCurrentTheme       NOTIFY themeChanged)
    Q_PROPERTY(bool    reduceMotion       READ reduceMotion       WRITE setReduceMotion       NOTIFY motionChanged)
    Q_PROPERTY(bool    reduceTransparency READ reduceTransparency WRITE setReduceTransparency NOTIFY transparencyChanged)

public:
    explicit Theme(QObject *parent = nullptr);
    ~Theme() override;

    /// Used by QML_SINGLETON to provide the singleton instance.
    static Theme *create(QObject *parent = nullptr);

    // Color accessors — delegate to Tokens::instance()
    QColor surface0()      const;
    QColor surface1()      const;
    QColor surface2()      const;
    QColor surface3()      const;
    QColor surface4()      const;
    QColor fgPrimary()     const;
    QColor fgSecondary()   const;
    QColor fgTertiary()    const;
    QColor fgDisabled()    const;
    QColor fgInverse()     const;
    QColor accent300()     const;
    QColor accent500()     const;
    QColor accent700()     const;
    QColor accent900()     const;
    QColor success()       const;
    QColor warning()       const;
    QColor danger()        const;
    QColor borderSubtle()  const;
    QColor borderDefault() const;

    // Spacing
    int space1() const;
    int space2() const;
    int space3() const;
    int space4() const;
    int space5() const;
    int space6() const;

    // Radius
    int radiusSm()   const;
    int radiusMd()   const;
    int radiusLg()   const;
    int radiusXl()   const;
    int radiusFull() const;

    // Motion
    int motionDefault() const;
    int motionFast()    const;
    int motionSlow()    const;

    // Typography
    QString fontFamily()     const;
    QString fontFamilyMono() const;

    // State
    QString currentTheme()       const;
    bool    reduceMotion()       const;
    bool    reduceTransparency() const;

    Q_INVOKABLE QStringList availableThemes() const;

public slots:
    void setCurrentTheme(const QString &name);
    void setReduceMotion(bool on);
    void setReduceTransparency(bool on);

signals:
    void themeChanged();
    void motionChanged();
    void transparencyChanged();

private:
    void onTokensThemeChanged();
    void onTokensMotionChanged();
    void onTokensTransparencyChanged();
};

}  // namespace Orion
