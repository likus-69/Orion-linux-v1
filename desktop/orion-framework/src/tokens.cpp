// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/tokens.cpp — design-token loader and runtime theme manager.

#include "tokens.h"

#include "settings.h"
#include "log.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>

namespace Orion {

Tokens *Tokens::s_instance = nullptr;

namespace {
QString asString(const QJsonValue &v)
{
    return v.isString() ? v.toString() : QString();
}

QColor asColor(const QJsonValue &v)
{
    const QString s = asString(v);
    return s.isEmpty() ? QColor() : QColor(s);
}

QStringList candidatePaths()
{
    return {
        QStringLiteral(":/orion/tokens.json"),
        QStringLiteral(":/qml/data/tokens.json"),
        QStringLiteral(":/data/tokens.json"),
        QStringLiteral("data/tokens.json"),
    };
}
}  // namespace

Tokens *Tokens::instance()
{
    if (!s_instance) {
        s_instance = new Tokens();
        s_instance->load();
        s_instance->loadPersistedState();
    }
    return s_instance;
}

Tokens::Tokens(QObject *parent)
    : QObject(parent)
    , m_loaded(false)
    , m_currentTheme(QStringLiteral("orion-dark"))
    , m_fontFamily(QStringLiteral("Inter"))
    , m_fontFamilyMono(QStringLiteral("JetBrains Mono"))
    , m_fontFamilyCjk(QStringLiteral("Noto Sans CJK SC"))
    , m_motionEasing(QStringLiteral("cubic-bezier(0.2, 0.0, 0.0, 1.0)"))
    , m_reduceMotion(false)
    , m_reduceTransparency(false)
{
}

bool Tokens::load()
{
    for (const QString &path : candidatePaths()) {
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
            continue;
        const QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
        if (!doc.isObject())
            continue;
        m_root = doc.object();
        m_loaded = true;

        // Cache global typography
        const QJsonObject typo = m_root.value(QStringLiteral("typography")).toObject();
        m_fontFamily     = typo.value(QStringLiteral("font_family")).toString(m_fontFamily);
        m_fontFamilyMono = typo.value(QStringLiteral("font_family_mono")).toString(m_fontFamilyMono);
        m_fontFamilyCjk  = typo.value(QStringLiteral("font_family_cjk")).toString(m_fontFamilyCjk);

        // Cache motion easing
        const QJsonObject motion = m_root.value(QStringLiteral("motion")).toObject();
        m_motionEasing = motion.value(QStringLiteral("easing")).toString(m_motionEasing);

        // Apply the current theme to populate color ramps
        const QJsonObject themes = m_root.value(QStringLiteral("themes")).toObject();
        const QJsonObject theme = themes.value(m_currentTheme).toObject();
        if (!theme.isEmpty()) {
            applyTheme(theme);
        } else if (themes.contains(QStringLiteral("orion-dark"))) {
            m_currentTheme = QStringLiteral("orion-dark");
            applyTheme(themes.value(m_currentTheme).toObject());
        }

        qCDebug(orionFramework) << "Tokens: loaded from" << path
                                 << "; current theme =" << m_currentTheme;
        return true;
    }
    qCWarning(orionFramework) << "Tokens: failed to load tokens.json from any candidate path";
    m_loaded = false;
    return false;
}

void Tokens::applyTheme(const QJsonObject &theme)
{
    const QJsonObject surface = theme.value(QStringLiteral("surface")).toObject();
    m_surface.c0 = asColor(surface.value(QStringLiteral("0")));
    m_surface.c1 = asColor(surface.value(QStringLiteral("1")));
    m_surface.c2 = asColor(surface.value(QStringLiteral("2")));
    m_surface.c3 = asColor(surface.value(QStringLiteral("3")));
    m_surface.c4 = asColor(surface.value(QStringLiteral("4")));

    const QJsonObject fg = theme.value(QStringLiteral("foreground")).toObject();
    m_foreground.primary   = asColor(fg.value(QStringLiteral("primary")));
    m_foreground.secondary = asColor(fg.value(QStringLiteral("secondary")));
    m_foreground.tertiary  = asColor(fg.value(QStringLiteral("tertiary")));
    m_foreground.disabled  = asColor(fg.value(QStringLiteral("disabled")));
    m_foreground.inverse   = asColor(fg.value(QStringLiteral("inverse")));

    const QJsonObject accent = theme.value(QStringLiteral("accent")).toObject();
    m_accent.c50  = asColor(accent.value(QStringLiteral("50")));
    m_accent.c100 = asColor(accent.value(QStringLiteral("100")));
    m_accent.c300 = asColor(accent.value(QStringLiteral("300")));
    m_accent.c500 = asColor(accent.value(QStringLiteral("500")));
    m_accent.c700 = asColor(accent.value(QStringLiteral("700")));
    m_accent.c900 = asColor(accent.value(QStringLiteral("900")));

    const QJsonObject semantic = theme.value(QStringLiteral("semantic")).toObject();
    m_semantic.success = asColor(semantic.value(QStringLiteral("success")));
    m_semantic.warning = asColor(semantic.value(QStringLiteral("warning")));
    m_semantic.danger  = asColor(semantic.value(QStringLiteral("danger")));
    m_semantic.info    = asColor(semantic.value(QStringLiteral("info")));

    const QJsonObject border = theme.value(QStringLiteral("border")).toObject();
    m_border.subtle = asColor(border.value(QStringLiteral("subtle")));
    m_border.deflt  = asColor(border.value(QStringLiteral("default")));
    m_border.strong = asColor(border.value(QStringLiteral("strong")));
    m_border.focus  = asColor(border.value(QStringLiteral("focus")));
}

QStringList Tokens::availableThemes() const
{
    if (!m_loaded)
        return QStringList{ QStringLiteral("orion-dark") };
    const QJsonValue themes = m_root.value(QStringLiteral("themes"));
    if (!themes.isObject())
        return QStringList{ QStringLiteral("orion-dark") };
    QStringList out = themes.toObject().keys();
    if (out.isEmpty())
        out.append(QStringLiteral("orion-dark"));
    return out;
}

bool Tokens::setTheme(const QString &name)
{
    if (!m_loaded)
        return false;
    const QJsonValue themes = m_root.value(QStringLiteral("themes"));
    if (!themes.isObject())
        return false;
    const QJsonObject theme = themes.toObject().value(name).toObject();
    if (theme.isEmpty()) {
        qCWarning(orionFramework) << "Tokens::setTheme: unknown theme" << name;
        return false;
    }
    if (name == m_currentTheme)
        return true;
    m_currentTheme = name;
    applyTheme(theme);

    // Persist
    Settings s(QStringLiteral("theme"));
    s.set(QStringLiteral("currentTheme"), name);

    emit themeChanged();
    return true;
}

int Tokens::spacing(int i) const
{
    if (!m_loaded)
        return 0;
    return m_root.value(QStringLiteral("spacing")).toObject()
            .value(QString::number(i)).toInt(0);
}

int Tokens::radius(const QString &name) const
{
    if (!m_loaded)
        return 0;
    return m_root.value(QStringLiteral("radius")).toObject()
            .value(name).toInt(0);
}

int Tokens::motionDuration(const QString &name) const
{
    if (m_reduceMotion)
        return 0;
    if (!m_loaded)
        return 0;
    return m_root.value(QStringLiteral("motion")).toObject()
            .value(name).toInt(0);
}

void Tokens::setReduceMotion(bool on)
{
    if (on == m_reduceMotion)
        return;
    m_reduceMotion = on;
    Settings s(QStringLiteral("theme"));
    s.set(QStringLiteral("reduceMotion"), on);
    emit motionChanged();
}

void Tokens::setReduceTransparency(bool on)
{
    if (on == m_reduceTransparency)
        return;
    m_reduceTransparency = on;
    Settings s(QStringLiteral("theme"));
    s.set(QStringLiteral("reduceTransparency"), on);
    emit transparencyChanged();
}

void Tokens::loadPersistedState()
{
    Settings s(QStringLiteral("theme"));
    const QString name = s.getString(QStringLiteral("currentTheme"),
                                       QStringLiteral("orion-dark"));
    if (availableThemes().contains(name)) {
        // Re-apply (without persisting) to update ramps.
        if (m_loaded) {
            const QJsonObject theme = m_root.value(QStringLiteral("themes")).toObject()
                                         .value(name).toObject();
            if (!theme.isEmpty()) {
                m_currentTheme = name;
                applyTheme(theme);
            }
        }
    } else {
        qCWarning(orionFramework) << "Tokens: persisted theme" << name << "not in tokens.json";
    }
    m_reduceMotion = s.getBool(QStringLiteral("reduceMotion"), false);
    m_reduceTransparency = s.getBool(QStringLiteral("reduceTransparency"), false);
}

}  // namespace Orion
