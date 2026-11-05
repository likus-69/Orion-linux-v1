# Orion OS — Design System

This document defines Orion OS's visual language. Every Orion-branded desktop
component **must** use these tokens. Hard-coded colors, magic spacing numbers,
or arbitrary font sizes in component code are bugs.

The canonical source of truth for tokens is
[`desktop/orion-framework/data/tokens.json`](../desktop/orion-framework/data/tokens.json),
which is the file actually loaded by `org.orion.framework.Theme`. This document
is the human-readable mirror.

## 1. Design philosophy

Orion OS aims for a futuristic but professional aesthetic: deep navy and
charcoal backgrounds, blue/cyan/violet accent colors, subtle transparency and
blur, rounded corners, generous spacing, carefully controlled animations, and
high-quality light and dark themes that remain readable on lower-end hardware.

The interface should feel like a distinct operating system, not a clone of
Windows or of any other existing desktop. Inspiration from familiar workflows
is fine; copying proprietary assets is not.

Three guiding principles:

1. **Hierarchy over decoration.** Visual weight directs attention; ornament is
   rare and purposeful.
2. **Calm motion.** Animations communicate state changes; they never decorate.
3. **Accessibility is non-negotiable.** Contrast, focus indicators, keyboard
   navigation, and reduced-motion support are first-class.

## 2. Color tokens

All Orion colors are defined as HSL-derived hex values. Each color has a
"ramp" of shades from 50 (lightest) to 950 (darkest). The accent ramp is
themed — different Orion themes (Dark, Light, Midnight, Aurora) substitute
different ramps without changing the token names.

### 2.1 Surface ramp (backgrounds)

| Token | Dark value | Light value |
|---|---|---|
| `surface.0` (canvas) | `#0B0F1A` | `#F7F9FC` |
| `surface.1` (raised) | `#131826` | `#FFFFFF` |
| `surface.2` (card) | `#1A2030` | `#FFFFFF` |
| `surface.3` (overlay) | `#222B3F` | `#FFFFFF` |
| `surface.4` (active) | `#2C3650` | `#EEF1F6` |

### 2.2 Foreground ramp (text, icons)

| Token | Dark value | Light value |
|---|---|---|
| `fg.primary` | `#F2F4F8` | `#1A1F2E` |
| `fg.secondary` | `#B6BDD0` | `#4A5468` |
| `fg.tertiary` | `#7E8699` | `#7A8294` |
| `fg.disabled` | `#4A5066` | `#C2C8D5` |
| `fg.inverse` | `#0B0F1A` | `#FFFFFF` |

### 2.3 Accent ramp (interactive elements)

| Token | Dark value | Light value |
|---|---|---|
| `accent.50` | `#E6F0FF` | `#E6F0FF` |
| `accent.100` | `#C2D8FF` | `#C2D8FF` |
| `accent.300` | `#5C9DFF` | `#3F8CFF` |
| `accent.500` (default) | `#2D7FF9` | `#0F6FE8` |
| `accent.700` | `#1E5BB8` | `#0B53C4` |
| `accent.900` | `#0F3576` | `#082862` |

The default accent is blue (`#2D7FF9` in dark, `#0F6FE8` in light). Users can
choose an alternate accent in Settings → Personalization → Accent Color; the
available presets are:

- **Blue** (default)
- **Cyan** (`#0FB3D9`)
- **Violet** (`#7C5CFF`)
- **Magenta** (`#E14FA8`)
- **Amber** (`#F2A93B`)
- **Emerald** (`#2FB57C`)
- **Crimson** (`#E14B4B`)

### 2.4 Semantic colors

| Token | Dark value | Light value | Use |
|---|---|---|---|
| `success` | `#3FBF7F` | `#1FA15F` | Successful operations |
| `warning` | `#F2A93B` | `#D88200` | Warnings |
| `danger` | `#E14B4B` | `#C42F2F` | Destructive actions |
| `info` | `#2D7FF9` | `#0F6FE8` | Informational |

### 2.5 Border and stroke

| Token | Dark value | Light value |
|---|---|---|
| `border.subtle` | `#222B3F` | `#E2E6EE` |
| `border.default` | `#2C3650` | `#CBD2DE` |
| `border.strong` | `#3D4866` | `#9CA4B5` |
| `border.focus` | `accent.500` | `accent.500` |

## 3. Typography

Orion OS ships **Inter** (sans) and **JetBrains Mono** (monospace) by default.
CJK fallback is **Noto Sans CJK**.

| Token | Font | Size | Weight | Line height |
|---|---|---|---|---|
| `text.display` | Inter | 32px | 600 | 1.2 |
| `text.h1` | Inter | 24px | 600 | 1.3 |
| `text.h2` | Inter | 20px | 600 | 1.3 |
| `text.h3` | Inter | 18px | 500 | 1.4 |
| `text.body` | Inter | 15px | 400 | 1.5 |
| `text.body-strong` | Inter | 15px | 600 | 1.5 |
| `text.caption` | Inter | 13px | 400 | 1.4 |
| `text.overline` | Inter | 11px | 600 | 1.2 |
| `text.mono` | JetBrains Mono | 14px | 400 | 1.4 |

Letter-spacing: `text.overline` uses `+0.6px` for tracking. All others use 0.

The scale above is the base at 100% display scaling. At 125%, 150%, 200% the
sizes scale proportionally.

## 4. Spacing

Orion uses a 4-pixel base grid.

| Token | Pixels |
|---|---|
| `space.0` | 0 |
| `space.1` | 4 |
| `space.2` | 8 |
| `space.3` | 12 |
| `space.4` | 16 |
| `space.5` | 20 |
| `space.6` | 24 |
| `space.8` | 32 |
| `space.10` | 40 |
| `space.12` | 48 |
| `space.16` | 64 |

Spacing inside a component should always be a token, never a literal number.

## 5. Border radius

| Token | Radius | Use |
|---|---|---|
| `radius.none` | 0 | Dividers, table cells |
| `radius.sm` | 4px | Small chips, tags |
| `radius.md` | 8px | Buttons, inputs |
| `radius.lg` | 12px | Cards, dialogs |
| `radius.xl` | 16px | Panels, modals |
| `radius.full` | 9999px | Pills, circular avatars |

## 6. Elevation / shadows

| Token | Dark shadow | Light shadow |
|---|---|---|
| `elevation.0` | none | none |
| `elevation.1` | `0 1px 2px rgba(0,0,0,0.4)` | `0 1px 2px rgba(20,30,60,0.08)` |
| `elevation.2` | `0 2px 8px rgba(0,0,0,0.45)` | `0 2px 8px rgba(20,30,60,0.10)` |
| `elevation.3` | `0 8px 24px rgba(0,0,0,0.5)` | `0 8px 24px rgba(20,30,60,0.14)` |
| `elevation.4` | `0 16px 48px rgba(0,0,0,0.55)` | `0 16px 48px rgba(20,30,60,0.20)` |

## 7. Blur / transparency

| Token | Blur radius | Opacity |
|---|---|---|
| `blur.none` | 0px | 100% |
| `blur.subtle` | 16px | 90% |
| `blur.default` | 32px | 80% |
| `blur.strong` | 64px | 70% |

These can be disabled in Settings → Personalization → Animations (the "Reduce
transparency effects" toggle). When disabled, components fall back to the
underlying surface color at 100% opacity.

## 8. Animation

| Token | Duration | Easing | Use |
|---|---|---|---|
| `motion.instant` | 0ms | — | No animation |
| `motion.fast` | 120ms | `ease-out` | Hover, focus, press |
| `motion.default` | 200ms | `cubic-bezier(0.2, 0.0, 0.0, 1.0)` | Open/close, slide |
| `motion.slow` | 320ms | `cubic-bezier(0.2, 0.0, 0.0, 1.0)` | Page transitions |
| `motion.slower` | 480ms | `cubic-bezier(0.2, 0.0, 0.0, 1.0)` | First-launch animations |

The "Reduce animations" toggle in Settings replaces all motion with
`motion.instant`.

## 9. Iconography

Orion OS uses a custom icon set called **Orion Icons** (SVG, monochrome,
24x24 default grid, 20x24 stroke). All icons are designed to:

- Be readable at 16px and 24px.
- Use a consistent stroke width (1.5px at 24px).
- Snap to a 24x24 grid.
- Use only `currentColor` for fill / stroke so they inherit the surrounding
  text color.

Existing upstream icons (Breeze, Papirus, Adwaita) are used as a fallback when
an Orion-native icon does not exist yet. The icon theme precedence configured
in `distro/defaults/icon-theme-orion.conf` is:

1. Orion
2. Breeze
3. Breeze Dark
4. Papirus
5. hicolor

## 10. Component anatomy

### Button

- Height: 36px (default), 28px (compact), 44px (large).
- Padding: `space.3` horizontal.
- Border radius: `radius.md`.
- Default state: `surface.2` background, `border.default` border.
- Hover state: `surface.3` background, `accent.500` border.
- Active state: `surface.4` background, `accent.700` border.
- Focus ring: `accent.500` outline at 2px offset 2px.
- Disabled: `fg.disabled` text, `surface.1` background, no hover.

### Primary button

- Background: `accent.500`.
- Foreground: `fg.inverse`.
- Hover: `accent.700`.
- Active: `accent.900`.

### Card

- Background: `surface.2`.
- Border: `1px solid border.subtle`.
- Border radius: `radius.lg`.
- Padding: `space.4`.
- Shadow: `elevation.1` (resting), `elevation.2` (hover).
- Click: optional — use only if the card is interactive.

### Input field

- Height: 36px.
- Padding: `space.2` `space.3`.
- Border radius: `radius.md`.
- Default: `surface.1` background, `border.default`.
- Focus: `accent.500` border, no shadow.
- Error: `danger` border, `danger` caption text below.

### List row

- Height: 40px (default), 32px (compact), 48px (large).
- Padding: `space.2` `space.3`.
- Hover: `surface.3` background.
- Active: `surface.4` background.
- Selected: `accent.500` at 20% opacity background, `accent.500` 2px left bar.

### Panel (taskbar)

- Height: 48px (default), 36px (compact), 56px (large).
- Background: `surface.1` at `blur.default` (or `surface.1` at 100% if blur
  disabled).
- Border top: `1px solid border.subtle`.
- Padding: `space.2` horizontal.

## 11. Icon usage

- Always pair an icon with a text label unless the icon is universally
  recognized (close, search, settings).
- Never use a decorative icon in place of meaningful copy.
- Icon + text spacing: `space.2`.
- Icon size: 16px in compact density, 20px in default, 24px in large.

## 12. Themes

Five themes are shipped by default; each substitutes color ramps while
keeping all token names identical.

| Theme | Surface 0 | Surface 1 | Accent 500 | Notes |
|---|---|---|---|---|
| **Orion Dark** (default) | `#0B0F1A` | `#131826` | `#2D7FF9` | The default look |
| **Orion Light** | `#F7F9FC` | `#FFFFFF` | `#0F6FE8` | Daytime / office |
| **Orion Midnight** | `#04060B` | `#080B14` | `#7C5CFF` | OLED-friendly, violet accent |
| **Orion Aurora** | `#0A1A14` | `#0F2419` | `#2FB57C` | Emerald accent, dark green |
| **Orion High Contrast** | `#000000` | `#000000` | `#FFFFFF` | WCAG AAA, no blur, no gradients |

The High Contrast theme is not just a recolor — it disables blur, gradients,
and subtle shadows entirely.

## 13. Reduced-motion and reduced-transparency

Two global toggles in Settings → Personalization → Animations:

- **Reduce animations:** replaces every `motion.*` token with `motion.instant`.
- **Reduce transparency effects:** replaces every `blur.*` token with
  `blur.none` and uses the underlying surface color at 100% opacity.

Both toggles are honored at the `org.orion.framework.Theme` level, so every
component that reads tokens automatically honors them. Hard-coded animations
or alpha values in component code are bugs.

## 14. Accessibility

- Minimum contrast ratio: **4.5:1** for body text, **3:1** for large text and
  UI elements. Verified by the design-token tests in
  `tests/unit/test_tokens.py`.
- Focus indicators are always visible: 2px solid `accent.500` outline, 2px
  offset. No `outline: none`.
- Keyboard navigation: every interactive element must be reachable via Tab and
  operable via Enter/Space/Arrow keys.
- Screen reader: every interactive element must have an accessible name
  (`Accessible.name` in QML).
- Reduced motion is honored globally; no animation may run if the user has
  reduced-motion enabled.
- Reduced transparency is honored globally.
- High-contrast theme is available and tested.
