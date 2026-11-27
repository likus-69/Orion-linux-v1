// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/theme.cpp — Orion Theme QML singleton implementation.

#include "theme.h"
#include "tokens.h"

#include <QObject>

namespace Orion {

Theme::Theme(QObject *parent)
    : QObject(parent)
{
    // Force-load the Tokens singleton so colors are populated immediately.
    Tokens *t = Tokens::instance();

    // Forward Tokens signals so QML bindings re-evaluate.
    connect(t, &Tokens::themeChanged,         this, &Theme::themeChanged);
    connect(t, &Tokens::motionChanged,        this, &Theme::motionChanged);
    connect(t, &Tokens::transparencyChanged,  this, &Theme::transparencyChanged);
}

Theme::~Theme() = default;

Theme *Theme::create(QObject *parent)
{
    return new Theme(parent);
}

// Color accessors
QColor Theme::surface0()      const { return Tokens::instance()->surface().c0; }
QColor Theme::surface1()      const { return Tokens::instance()->surface().c1; }
QColor Theme::surface2()      const { return Tokens::instance()->surface().c2; }
QColor Theme::surface3()      const { return Tokens::instance()->surface().c3; }
QColor Theme::surface4()      const { return Tokens::instance()->surface().c4; }
QColor Theme::fgPrimary()     const { return Tokens::instance()->foreground().primary; }
QColor Theme::fgSecondary()   const { return Tokens::instance()->foreground().secondary; }
QColor Theme::fgTertiary()    const { return Tokens::instance()->foreground().tertiary; }
QColor Theme::fgDisabled()    const { return Tokens::instance()->foreground().disabled; }
QColor Theme::fgInverse()     const { return Tokens::instance()->foreground().inverse; }
QColor Theme::accent300()     const { return Tokens::instance()->accent().c300; }
QColor Theme::accent500()     const { return Tokens::instance()->accent().c500; }
QColor Theme::accent700()     const { return Tokens::instance()->accent().c700; }
QColor Theme::accent900()     const { return Tokens::instance()->accent().c900; }
QColor Theme::success()       const { return Tokens::instance()->semantic().success; }
QColor Theme::warning()       const { return Tokens::instance()->semantic().warning; }
QColor Theme::danger()        const { return Tokens::instance()->semantic().danger; }
QColor Theme::borderSubtle()  const { return Tokens::instance()->border().subtle; }
QColor Theme::borderDefault() const { return Tokens::instance()->border().deflt; }

// Spacing
int Theme::space1() const { return Tokens::instance()->spacing(1); }  // 4
int Theme::space2() const { return Tokens::instance()->spacing(2); }  // 8
int Theme::space3() const { return Tokens::instance()->spacing(3); }  // 12
int Theme::space4() const { return Tokens::instance()->spacing(4); }  // 16
int Theme::space5() const { return Tokens::instance()->spacing(5); }  // 20
int Theme::space6() const { return Tokens::instance()->spacing(6); }  // 24

// Radius
int Theme::radiusSm()   const { return Tokens::instance()->radius(QStringLiteral("sm")); }
int Theme::radiusMd()   const { return Tokens::instance()->radius(QStringLiteral("md")); }
int Theme::radiusLg()   const { return Tokens::instance()->radius(QStringLiteral("lg")); }
int Theme::radiusXl()   const { return Tokens::instance()->radius(QStringLiteral("xl")); }
int Theme::radiusFull() const { return Tokens::instance()->radius(QStringLiteral("full")); }

// Motion
int Theme::motionDefault() const { return Tokens::instance()->motionDuration(QStringLiteral("default")); }
int Theme::motionFast()    const { return Tokens::instance()->motionDuration(QStringLiteral("fast")); }
int Theme::motionSlow()    const { return Tokens::instance()->motionDuration(QStringLiteral("slow")); }

// Typography
QString Theme::fontFamily()     const { return Tokens::instance()->fontFamily(); }
QString Theme::fontFamilyMono() const { return Tokens::instance()->fontFamilyMono(); }

// State
QString Theme::currentTheme()       const { return Tokens::instance()->currentThemeName(); }
bool    Theme::reduceMotion()       const { return Tokens::instance()->reduceMotion(); }
bool    Theme::reduceTransparency() const { return Tokens::instance()->reduceTransparency(); }

QStringList Theme::availableThemes() const
{
    return Tokens::instance()->availableThemes();
}

void Theme::setCurrentTheme(const QString &name)
{
    Tokens::instance()->setTheme(name);  // emits themeChanged() → forwarded
}

void Theme::setReduceMotion(bool on)
{
    Tokens::instance()->setReduceMotion(on);
}

void Theme::setReduceTransparency(bool on)
{
    Tokens::instance()->setReduceTransparency(on);
}

void Theme::onTokensThemeChanged()        { emit themeChanged(); }
void Theme::onTokensMotionChanged()       { emit motionChanged(); }
void Theme::onTokensTransparencyChanged() { emit transparencyChanged(); }

}  // namespace Orion
