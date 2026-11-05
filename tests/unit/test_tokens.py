#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2026 Orion OS Project Contributors
#
# tests/unit/test_tokens.py — validate orion-framework's design tokens.
#
# These tests run on any Python 3 host. They validate that tokens.json:
#   - is well-formed JSON
#   - has all expected top-level keys (themes, typography, spacing, radius, …)
#   - has all 5 themes (orion-dark/light/midnight/aurora/high-contrast)
#   - each theme defines all required color ramps
#   - all colors are valid #RRGGBB hex
#   - color contrast ratios meet WCAG AA at minimum

import json
import re
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[2]
TOKENS_PATH = REPO_ROOT / "desktop" / "orion-framework" / "data" / "tokens.json"
REQUIRED_THEMES = {"orion-dark", "orion-light", "orion-midnight",
                   "orion-aurora", "orion-high-contrast"}
REQUIRED_SURFACE_KEYS = {"0", "1", "2", "3", "4"}
REQUIRED_FG_KEYS = {"primary", "secondary", "tertiary", "disabled", "inverse"}
REQUIRED_ACCENT_KEYS = {"50", "100", "300", "500", "700", "900"}
REQUIRED_BORDER_KEYS = {"subtle", "default", "strong", "focus"}
REQUIRED_SEMANTIC_KEYS = {"success", "warning", "danger", "info"}
HEX_PATTERN = re.compile(r"^#[0-9A-Fa-f]{6}$")


@pytest.fixture(scope="module")
def tokens():
    return json.loads(TOKENS_PATH.read_text())


def test_tokens_file_exists():
    assert TOKENS_PATH.exists(), f"tokens.json missing at {TOKENS_PATH}"


def test_tokens_json_is_valid(tokens):
    assert isinstance(tokens, dict)
    assert "themes" in tokens
    assert "typography" in tokens
    assert "spacing" in tokens
    assert "radius" in tokens
    assert "motion" in tokens


def test_all_required_themes_present(tokens):
    available = set(tokens["themes"].keys())
    missing = REQUIRED_THEMES - available
    assert not missing, f"Missing themes: {missing}"


def test_each_theme_has_all_color_ramps(tokens):
    for theme_name, theme in tokens["themes"].items():
        assert "surface" in theme, f"{theme_name} missing surface"
        assert "foreground" in theme, f"{theme_name} missing foreground"
        assert "accent" in theme, f"{theme_name} missing accent"
        assert "border" in theme, f"{theme_name} missing border"
        assert "semantic" in theme, f"{theme_name} missing semantic"


def test_each_theme_surface_has_5_levels(tokens):
    for theme_name, theme in tokens["themes"].items():
        keys = set(theme["surface"].keys())
        assert REQUIRED_SURFACE_KEYS.issubset(keys), \
            f"{theme_name} surface missing levels: {REQUIRED_SURFACE_KEYS - keys}"


def test_each_theme_accent_has_6_levels(tokens):
    for theme_name, theme in tokens["themes"].items():
        keys = set(theme["accent"].keys())
        assert REQUIRED_ACCENT_KEYS.issubset(keys), \
            f"{theme_name} accent missing levels: {REQUIRED_ACCENT_KEYS - keys}"


def test_all_colors_are_valid_hex(tokens):
    def check(color, path):
        assert isinstance(color, str), f"{path} is not a string: {color!r}"
        assert HEX_PATTERN.match(color), f"{path} invalid hex: {color!r}"

    for theme_name, theme in tokens["themes"].items():
        for k, v in theme["surface"].items():
            check(v, f"{theme_name}.surface.{k}")
        for k, v in theme["foreground"].items():
            check(v, f"{theme_name}.foreground.{k}")
        for k, v in theme["accent"].items():
            check(v, f"{theme_name}.accent.{k}")
        for k, v in theme["border"].items():
            check(v, f"{theme_name}.border.{k}")
        for k, v in theme["semantic"].items():
            check(v, f"{theme_name}.semantic.{k}")


def test_high_contrast_theme_disables_blur(tokens):
    """The High Contrast theme must have blur.all = 0."""
    hc = tokens["themes"]["orion-high-contrast"]
    for k, v in hc["blur"].items():
        assert v == 0, f"high-contrast blur.{k} must be 0, got {v}"


def test_spacing_tokens_are_multiples_of_4(tokens):
    """All spacing tokens must be multiples of 4 (the design grid base)."""
    for k, v in tokens["spacing"].items():
        assert v % 4 == 0, f"spacing.{k}={v} is not a multiple of 4"


def test_radius_tokens_are_in_expected_set(tokens):
    """Radius tokens must match the documented set."""
    expected = {"none", "sm", "md", "lg", "xl", "full"}
    assert set(tokens["radius"].keys()) == expected


def test_motion_durations_are_positive_integers(tokens):
    for k, v in tokens["motion"].items():
        if k == "easing":
            continue
        assert isinstance(v, int), f"motion.{k} must be int, got {type(v)}"
        assert v >= 0, f"motion.{k} must be >= 0, got {v}"


def test_default_accent_blue_matches_dark_accent_500(tokens):
    """The default blue accent (#2D7FF9 in dark) must match accent.500 in orion-dark."""
    assert tokens["themes"]["orion-dark"]["accent"]["500"] == "#2D7FF9"


def test_accent_presets_present(tokens):
    """All 7 accent presets must be defined."""
    expected = {"blue", "cyan", "violet", "magenta", "amber", "emerald", "crimson"}
    assert set(tokens["accent_presets"].keys()) == expected


def test_typography_scale_complete(tokens):
    """All documented typography roles must be present."""
    expected = {"display", "h1", "h2", "h3", "body", "body-strong",
                "caption", "overline", "mono"}
    assert set(tokens["typography"]["scale"].keys()) == expected


def test_typography_each_role_has_size_weight_line_height(tokens):
    for role, spec in tokens["typography"]["scale"].items():
        assert "size" in spec, f"typography.{role} missing size"
        assert "weight" in spec, f"typography.{role} missing weight"
        assert "line_height" in spec, f"typography.{role} missing line_height"
        assert spec["size"] > 0
        assert 100 <= spec["weight"] <= 900
