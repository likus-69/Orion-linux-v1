// SPDX-License-Identifier: GPL-3.0-or-later
// SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
//
// src/tokens.h — design-token loader and runtime theme manager.
//
// Loads `data/tokens.json` (shipped as a Qt resource at `:/orion/tokens.json`
// by the framework's qt_add_qml_module RESOURCES list) and provides typed
// access to:
//   - the list of available theme names
//   - per-theme color ramps (surface, foreground, accent, semantic, border)
//   - global typography / spacing / radius / motion tokens
//   - the *current* theme name, with persisted state and change signals
//
// Tokens is a process-wide singleton accessed via `Tokens::instance()`.
// The Theme QML singleton delegates to this class.
//
// The API mirrors what `tests/test_theme.cpp` exercises.

#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QColor>
#include <QJsonObject>

namespace Orion {

struct SurfaceRamp {
    QColor c0, c1, c2, c3, c4;
};

struct ForegroundRamp {
    QColor primary, secondary, tertiary, disabled, inverse;
};

struct AccentRamp {
    QColor c50, c100, c300, c500, c700, c900;
};

struct SemanticRamp {
    QColor success, warning, danger, info;
};

struct BorderRamp {
    QColor subtle, deflt, strong, focus;
};

class Tokens : public QObject
{
    Q_OBJECT
public:
    /// Returns the process-wide Tokens singleton. The first call loads
    /// tokens.json and the persisted current-theme setting from
    /// ~/.config/orion/theme.json (defaulting to "orion-dark").
    static Tokens *instance();

    /// Re-loads tokens.json from disk. Returns true on success. Safe to
    /// call multiple times; subsequent calls re-read the file.
    bool load();

    /// Returns the list of theme names available in tokens.json.
    QStringList availableThemes() const;

    /// Returns the current theme name (e.g. "orion-dark").
    QString currentThemeName() const { return m_currentTheme; }

    /// Switches to `name`. Returns true if the theme exists and was applied;
    /// false if the theme name is unknown (in which case currentTheme is
    /// unchanged). On success, persists the choice to ~/.config/orion/theme.json
    /// and emits themeChanged().
    bool setTheme(const QString &name);

    // Color ramps for the current theme
    SurfaceRamp    surface()    const { return m_surface; }
    ForegroundRamp foreground() const { return m_foreground; }
    AccentRamp     accent()     const { return m_accent; }
    SemanticRamp   semantic()   const { return m_semantic; }
    BorderRamp     border()     const { return m_border; }

    // Global typography
    QString fontFamily()     const { return m_fontFamily; }
    QString fontFamilyMono() const { return m_fontFamilyMono; }
    QString fontFamilyCjk()  const { return m_fontFamilyCjk; }

    /// Returns the spacing value for index `i` (0/1/2/3/4/5/6/8/10/12/16).
    int spacing(int i) const;

    /// Returns the radius value for `name` ("none"/"sm"/"md"/"lg"/"xl"/"full").
    int radius(const QString &name) const;

    /// Returns the motion duration for `name` ("instant"/"fast"/"default"/
    /// "slow"/"slower"). Returns 0 when reduceMotion is enabled.
    int motionDuration(const QString &name) const;

    /// Returns the motion easing string (CSS cubic-bezier form).
    QString motionEasing() const { return m_motionEasing; }

    bool reduceMotion() const { return m_reduceMotion; }
    void setReduceMotion(bool on);

    bool reduceTransparency() const { return m_reduceTransparency; }
    void setReduceTransparency(bool on);

signals:
    /// Emitted when setTheme() succeeds — all color ramp values change.
    void themeChanged();

    /// Emitted when reduceMotion changes — motionDuration() now returns 0
    /// for all keys.
    void motionChanged();

    /// Emitted when reduceTransparency changes.
    void transparencyChanged();

private:
    explicit Tokens(QObject *parent = nullptr);
    void loadPersistedState();
    void applyTheme(const QJsonObject &theme);

    static Tokens *s_instance;

    bool m_loaded;
    QString m_currentTheme;

    // Raw JSON for lookups that aren't cached as ramps
    QJsonObject m_root;

    // Cached ramps for the current theme
    SurfaceRamp    m_surface;
    ForegroundRamp m_foreground;
    AccentRamp     m_accent;
    SemanticRamp   m_semantic;
    BorderRamp     m_border;

    // Global typography
    QString m_fontFamily;
    QString m_fontFamilyMono;
    QString m_fontFamilyCjk;

    // Motion
    QString m_motionEasing;
    bool m_reduceMotion;
    bool m_reduceTransparency;
};

}  // namespace Orion
