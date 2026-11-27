// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/selftest.cpp — orion-framework-selftest binary.
//
// A small runtime self-test that exercises the framework's token loader,
// Settings round-trip, and Theme singleton construction. Exits 0 on success,
// non-zero on any failure. Intended to be run from the ISO's live session
// or from a build host as a smoke check.
//
// Usage:
//   orion-framework-selftest

#include "theme.h"
#include "settings.h"
#include "tokens.h"
#include "color.h"
#include "typography.h"
#include "about.h"
#include "hardware.h"
#include "log.h"

#include <QCoreApplication>
#include <QScopeGuard>

#include <cstdio>

static int failures = 0;

#define CHECK(cond, msg) \
    do { \
        if (!(cond)) { \
            std::fprintf(stderr, "FAIL: %s\n", msg); \
            ++failures; \
        } else { \
            std::fprintf(stdout, "ok:   %s\n", msg); \
        } \
    } while (0)

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    Orion::Log::installHandler();

    auto cleanup = qScopeGuard([] {
        std::printf("\n%d failure(s)\n", failures);
    });
    Q_UNUSED(cleanup);

    // ---- Tokens -------------------------------------------------------------
    Orion::Tokens tokens;
    CHECK(!tokens.themeNames().isEmpty(), "Tokens: themeNames non-empty");
    CHECK(tokens.themeNames().contains(QStringLiteral("orion-dark")),
          "Tokens: orion-dark present");
    CHECK(tokens.fontFamily() == QStringLiteral("Inter"),
          "Tokens: fontFamily=Inter");
    CHECK(tokens.fontFamilyMono() == QStringLiteral("JetBrains Mono"),
          "Tokens: fontFamilyMono=JetBrains Mono");
    CHECK(tokens.spacing(3) == 12, "Tokens: spacing(3)=12");
    CHECK(tokens.radius(QStringLiteral("md")) == 8, "Tokens: radius(md)=8");
    CHECK(tokens.motion().deflt == 200, "Tokens: motion.default=200");

    // ---- Theme --------------------------------------------------------------
    Orion::Theme theme;
    CHECK(theme.currentTheme() == QStringLiteral("orion-dark"),
          "Theme: default currentTheme=orion-dark");
    CHECK(theme.surface1().isValid(), "Theme: surface1 valid color");
    CHECK(theme.accent500().isValid(), "Theme: accent500 valid color");
    CHECK(theme.space3() == 12, "Theme: space3=12");
    CHECK(theme.radiusMd() == 8, "Theme: radiusMd=8");
    CHECK(theme.motionDefault() == 200, "Theme: motionDefault=200");
    theme.setReduceMotion(true);
    CHECK(theme.motionDefault() == 0, "Theme: motionDefault=0 when reduceMotion=true");
    theme.setReduceMotion(false);

    // Switch to orion-light, verify a color actually changed.
    const QColor darkAccent = theme.accent500();
    theme.setCurrentTheme(QStringLiteral("orion-light"));
    CHECK(theme.currentTheme() == QStringLiteral("orion-light"),
          "Theme: switched to orion-light");
    CHECK(theme.accent500() != darkAccent,
          "Theme: accent500 differs between dark and light themes");
    theme.setCurrentTheme(QStringLiteral("orion-dark"));

    // ---- Settings -----------------------------------------------------------
    Orion::Settings s(QStringLiteral("selftest"));
    s.set(QStringLiteral("test/key"), QStringLiteral("hello"));
    CHECK(s.getString(QStringLiteral("test/key")) == QStringLiteral("hello"),
          "Settings: round-trip string value");
    s.remove(QStringLiteral("test/key"));
    CHECK(!s.contains(QStringLiteral("test/key")),
          "Settings: removed key absent");

    // ---- Color helpers ------------------------------------------------------
    const QColor white(Qt::white);
    const QColor black(Qt::black);
    CHECK(Orion::Color::contrastRatio(white, black) > 20.0,
          "Color: white/black contrast > 20");
    CHECK(Orion::Color::isDark(black), "Color: isDark(black)=true");
    CHECK(!Orion::Color::isDark(white), "Color: isDark(white)=false");
    CHECK(Orion::Color::withAlpha(white, 0.5).alphaF() == 0.5,
          "Color: withAlpha(0.5) preserves other channels");

    // ---- Typography ---------------------------------------------------------
    Orion::Typography typo;
    CHECK(typo.fontFor(QStringLiteral("body")).pointSize() == 15,
          "Typography: body=15pt");
    CHECK(typo.fontFor(QStringLiteral("mono")).family() == QStringLiteral("JetBrains Mono"),
          "Typography: mono family=JetBrains Mono");

    // ---- About / Hardware (informational; no hard checks) -------------------
    Orion::About about;
    Orion::Hardware hw;
    std::printf("info: OS=%s %s\n", qPrintable(about.name()), qPrintable(about.version()));
    std::printf("info: CPU=%s cores=%d\n", qPrintable(hw.cpuModel()), hw.cpuCores());
    std::printf("info: RAM=%lld GiB\n", static_cast<long long>(hw.totalMemoryGB()));

    return failures == 0 ? 0 : 1;
}
