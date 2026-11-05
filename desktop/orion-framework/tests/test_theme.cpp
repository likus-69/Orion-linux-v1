// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// tests/test_theme.cpp — Qt unit tests for the Theme singleton.

#include "../src/theme.h"
#include "../src/tokens.h"
#include <QtTest/QtTest>

class TestTheme : public QObject {
    Q_OBJECT
private slots:
    void testTokensLoad() {
        auto *t = Orion::Tokens::instance();
        QVERIFY(t != nullptr);
        QVERIFY(t->load());
        QVERIFY(!t->availableThemes().isEmpty());
    }

    void testDefaultThemeIsDark() {
        auto *t = Orion::Tokens::instance();
        QVERIFY(t->availableThemes().contains(QStringLiteral("orion-dark")));
        QCOMPARE(t->currentThemeName(), QStringLiteral("orion-dark"));
    }

    void testSurfaceRampIsPopulated() {
        auto *t = Orion::Tokens::instance();
        QVERIFY(t->surface().c0.isValid());
        QVERIFY(t->surface().c1.isValid());
        QVERIFY(t->surface().c2.isValid());
    }

    void testAccentRampIsPopulated() {
        auto *t = Orion::Tokens::instance();
        QVERIFY(t->accent().c500.isValid());
        QCOMPARE(t->accent().c500, QColor(QStringLiteral("#2D7FF9")));
    }

    void testSwitchToLightTheme() {
        auto *t = Orion::Tokens::instance();
        QVERIFY(t->setTheme(QStringLiteral("orion-light")));
        QCOMPARE(t->currentThemeName(), QStringLiteral("orion-light"));
        QCOMPARE(t->accent().c500, QColor(QStringLiteral("#0F6FE8")));
        t->setTheme(QStringLiteral("orion-dark"));
    }

    void testSwitchToUnknownThemeFails() {
        auto *t = Orion::Tokens::instance();
        QVERIFY(!t->setTheme(QStringLiteral("nonexistent-theme")));
    }

    void testReduceMotionForcesZeroDuration() {
        auto *t = Orion::Tokens::instance();
        QVERIFY(t->motionDuration(QStringLiteral("fast")) > 0);
        t->setReduceMotion(true);
        QCOMPARE(t->motionDuration(QStringLiteral("fast")), 0);
        t->setReduceMotion(false);
    }
};

QTEST_MAIN(TestTheme)
#include "test_theme.moc"
