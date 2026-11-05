#!/usr/bin/env python3
"""
Orion OS branding generator.

Produces:
    distro/branding/orion-logo.svg
    distro/branding/orion-logo.png
    distro/branding/orion-logo-light.svg
    distro/branding/orion-logo-light.png
    distro/branding/orion-boot-splash.svg
    distro/branding/orion-boot-splash.png   (1920x1080)
    distro/branding/orion-icon.svg
    distro/branding/orion-icon.png          (256x256 app icon)

    wallpapers/orion-dark.svg
    wallpapers/orion-dark.png               (1920x1080)
    wallpapers/orion-light.svg
    wallpapers/orion-light.png              (1920x1080)
    wallpapers/orion-midnight.svg
    wallpapers/orion-midnight.png            (1920x1080)
    wallpapers/orion-aurora.svg
    wallpapers/orion-aurora.png              (1920x1080)

    distro/archiso/bootfiles/syslinux/splash.png (640x480)

Uses cairosvg to rasterize. The SVG content is generated programmatically so
the branding is reproducible.

Run from the repository root:

    python3 scripts/generate-branding.py
"""

import os
import sys
from pathlib import Path

try:
    import cairosvg
except ImportError:
    sys.exit("cairosvg is required: pip install cairosvg")

REPO_ROOT = Path(__file__).resolve().parent.parent
BRANDING_DIR = REPO_ROOT / "distro" / "branding"
WALLPAPERS_DIR = REPO_ROOT / "wallpapers"
SYSINUX_DIR = REPO_ROOT / "distro" / "archiso" / "bootfiles" / "syslinux"
BRANDING_DIR.mkdir(parents=True, exist_ok=True)
WALLPAPERS_DIR.mkdir(parents=True, exist_ok=True)
SYSINUX_DIR.mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------------------
# Orion logo: a constellation-inspired mark.
# ---------------------------------------------------------------------------
# The design: a ring (orbit) around a star at the center, with three
# "Orion's belt" stars arranged diagonally above. The color is the Orion
# blue accent (#2D7FF9) on transparent background. A dark version uses the
# same shape with a white ring (for dark backgrounds).
# ---------------------------------------------------------------------------
def orion_logo_svg(variant: str = "dark") -> str:
    if variant == "dark":
        # Logo for dark backgrounds: white star + blue ring.
        star_color = "#FFFFFF"
        ring_color = "#2D7FF9"
        belt_color = "#5C9DFF"
        text_color = "#FFFFFF"
    else:
        # Logo for light backgrounds: navy star + blue ring.
        star_color = "#0B0F1A"
        ring_color = "#0F6FE8"
        belt_color = "#1E5BB8"
        text_color = "#0B0F1A"

    return f"""<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <radialGradient id="starGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="{ring_color}" stop-opacity="0.9"/>
      <stop offset="60%" stop-color="{ring_color}" stop-opacity="0.2"/>
      <stop offset="100%" stop-color="{ring_color}" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="ringGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="{ring_color}"/>
      <stop offset="100%" stop-color="{belt_color}"/>
    </linearGradient>
  </defs>

  <!-- Outer glow -->
  <circle cx="128" cy="128" r="100" fill="url(#starGlow)"/>

  <!-- Orbital ring (an ellipse to suggest orbit + tilt) -->
  <ellipse cx="128" cy="128" rx="92" ry="38" fill="none"
           stroke="url(#ringGrad)" stroke-width="3.5"
           transform="rotate(-25 128 128)"/>
  <ellipse cx="128" cy="128" rx="92" ry="38" fill="none"
           stroke="url(#ringGrad)" stroke-width="3.5" stroke-opacity="0.4"
           transform="rotate(25 128 128)"/>

  <!-- Central star (4-pointed) -->
  <path d="M128 60 L138 116 L194 128 L138 140 L128 196 L118 140 L62 128 L118 116 Z"
        fill="{star_color}"/>

  <!-- Orion's belt: 3 stars arranged diagonally -->
  <circle cx="86" cy="200" r="5" fill="{belt_color}"/>
  <circle cx="128" cy="216" r="6" fill="{belt_color}"/>
  <circle cx="170" cy="232" r="5" fill="{belt_color}"/>

  <!-- Shoulder stars (Betelgeuse area) -->
  <circle cx="62" cy="92" r="4" fill="{belt_color}" opacity="0.85"/>
  <circle cx="194" cy="92" r="4" fill="{belt_color}" opacity="0.85"/>
</svg>
"""


# ---------------------------------------------------------------------------
# App icon: stylized star inside rounded square.
# ---------------------------------------------------------------------------
def orion_icon_svg() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256" width="256" height="256">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1A2030"/>
      <stop offset="100%" stop-color="#0B0F1A"/>
    </linearGradient>
    <linearGradient id="starGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#5C9DFF"/>
      <stop offset="100%" stop-color="#2D7FF9"/>
    </linearGradient>
  </defs>
  <rect x="16" y="16" width="224" height="224" rx="48" ry="48" fill="url(#bg)"/>
  <ellipse cx="128" cy="128" rx="80" ry="32" fill="none"
           stroke="#2D7FF9" stroke-width="2.5" stroke-opacity="0.55"
           transform="rotate(-25 128 128)"/>
  <path d="M128 64 L138 122 L196 128 L138 134 L128 192 L118 134 L60 128 L118 122 Z"
        fill="url(#starGrad)"/>
  <circle cx="92" cy="196" r="3" fill="#5C9DFF"/>
  <circle cx="128" cy="208" r="4" fill="#5C9DFF"/>
  <circle cx="164" cy="220" r="3" fill="#5C9DFF"/>
</svg>
"""


# ---------------------------------------------------------------------------
# Boot splash: simple spinner with the Orion logo on a dark background.
# ---------------------------------------------------------------------------
def orion_boot_splash_svg() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080" width="1920" height="1080">
  <defs>
    <radialGradient id="bg" cx="50%" cy="50%" r="75%">
      <stop offset="0%" stop-color="#131826"/>
      <stop offset="100%" stop-color="#0B0F1A"/>
    </radialGradient>
    <radialGradient id="starGlow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#2D7FF9" stop-opacity="0.85"/>
      <stop offset="60%" stop-color="#2D7FF9" stop-opacity="0.15"/>
      <stop offset="100%" stop-color="#2D7FF9" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <rect width="1920" height="1080" fill="url(#bg)"/>

  <!-- Central logo (scaled-up version of orion-logo-dark.svg) -->
  <g transform="translate(960 540)">
    <circle cx="0" cy="0" r="160" fill="url(#starGlow)"/>
    <ellipse cx="0" cy="0" rx="148" ry="60" fill="none"
             stroke="#2D7FF9" stroke-width="5"
             transform="rotate(-25)"/>
    <ellipse cx="0" cy="0" rx="148" ry="60" fill="none"
             stroke="#2D7FF9" stroke-width="5" stroke-opacity="0.4"
             transform="rotate(25)"/>
    <path d="M0 -110 L16 -22 L110 0 L16 22 L0 110 L-16 22 L-110 0 L-16 -22 Z" fill="#FFFFFF"/>
    <circle cx="-80" cy="138" r="8" fill="#5C9DFF"/>
    <circle cx="0" cy="158" r="10" fill="#5C9DFF"/>
    <circle cx="80" cy="178" r="8" fill="#5C9DFF"/>
  </g>

  <!-- Wordmark -->
  <text x="960" y="820" text-anchor="middle"
        font-family="Inter, Helvetica, Arial, sans-serif"
        font-size="44" font-weight="600" letter-spacing="6"
        fill="#B6BDD0">ORION OS</text>

  <!-- Spinner ring (static; Plymouth animates it via script) -->
  <circle cx="960" cy="900" r="14" fill="none" stroke="#2C3650" stroke-width="4"/>
  <path d="M 960 886 A 14 14 0 0 1 974 900" fill="none"
        stroke="#2D7FF9" stroke-width="4" stroke-linecap="round"/>

  <!-- Footer -->
  <text x="960" y="1020" text-anchor="middle"
        font-family="Inter, Helvetica, Arial, sans-serif"
        font-size="18" fill="#4A5066" letter-spacing="2">
    github.com/likus-69/Orion-linux-v1.1
  </text>
</svg>
"""


# ---------------------------------------------------------------------------
# Wallpapers — four variants, all 1920x1080, with subtle star-field + gradient
# ---------------------------------------------------------------------------
def wallpaper_dark() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080" width="1920" height="1080">
  <defs>
    <radialGradient id="bg" cx="50%" cy="50%" r="80%">
      <stop offset="0%" stop-color="#1A2030"/>
      <stop offset="60%" stop-color="#0F1320"/>
      <stop offset="100%" stop-color="#070A12"/>
    </radialGradient>
    <radialGradient id="starGlow" cx="50%" cy="40%" r="40%">
      <stop offset="0%" stop-color="#2D7FF9" stop-opacity="0.30"/>
      <stop offset="40%" stop-color="#2D7FF9" stop-opacity="0.10"/>
      <stop offset="100%" stop-color="#2D7FF9" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="orbit" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#2D7FF9" stop-opacity="0.7"/>
      <stop offset="100%" stop-color="#7C5CFF" stop-opacity="0.4"/>
    </linearGradient>
  </defs>

  <rect width="1920" height="1080" fill="url(#bg)"/>
  <rect width="1920" height="1080" fill="url(#starGlow)"/>

  <!-- Diagonal orbit -->
  <ellipse cx="960" cy="540" rx="700" ry="200" fill="none"
           stroke="url(#orbit)" stroke-width="2" stroke-opacity="0.55"
           transform="rotate(-15 960 540)"/>
  <ellipse cx="960" cy="540" rx="500" ry="140" fill="none"
           stroke="url(#orbit)" stroke-width="2" stroke-opacity="0.40"
           transform="rotate(15 960 540)"/>

  <!-- Central star -->
  <path d="M960 320 L985 510 L1180 540 L985 570 L960 760 L935 570 L740 540 L935 510 Z"
        fill="#FFFFFF" opacity="0.92"/>

  <!-- Orion's belt -->
  <circle cx="820" cy="820" r="6" fill="#5C9DFF"/>
  <circle cx="960" cy="860" r="7" fill="#5C9DFF"/>
  <circle cx="1100" cy="900" r="6" fill="#5C9DFF"/>

  <!-- Star field -->
  <g fill="#FFFFFF">
    <circle cx="120" cy="180" r="1.5" opacity="0.8"/>
    <circle cx="280" cy="320" r="1" opacity="0.6"/>
    <circle cx="430" cy="100" r="1.5" opacity="0.7"/>
    <circle cx="610" cy="220" r="1" opacity="0.5"/>
    <circle cx="1700" cy="140" r="1.5" opacity="0.7"/>
    <circle cx="1540" cy="300" r="1" opacity="0.5"/>
    <circle cx="1380" cy="100" r="1.5" opacity="0.7"/>
    <circle cx="1800" cy="900" r="1" opacity="0.6"/>
    <circle cx="1600" cy="980" r="1.5" opacity="0.8"/>
    <circle cx="140" cy="900" r="1" opacity="0.5"/>
    <circle cx="240" cy="980" r="1.5" opacity="0.7"/>
  </g>
</svg>
"""


def wallpaper_light() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080" width="1920" height="1080">
  <defs>
    <radialGradient id="bg" cx="50%" cy="50%" r="80%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#F1F4F9"/>
      <stop offset="100%" stop-color="#E2E6EE"/>
    </radialGradient>
    <radialGradient id="starGlow" cx="50%" cy="40%" r="40%">
      <stop offset="0%" stop-color="#0F6FE8" stop-opacity="0.18"/>
      <stop offset="100%" stop-color="#0F6FE8" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="orbit" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0F6FE8" stop-opacity="0.55"/>
      <stop offset="100%" stop-color="#7C5CFF" stop-opacity="0.30"/>
    </linearGradient>
  </defs>

  <rect width="1920" height="1080" fill="url(#bg)"/>
  <rect width="1920" height="1080" fill="url(#starGlow)"/>

  <ellipse cx="960" cy="540" rx="700" ry="200" fill="none"
           stroke="url(#orbit)" stroke-width="2" stroke-opacity="0.50"
           transform="rotate(-15 960 540)"/>
  <ellipse cx="960" cy="540" rx="500" ry="140" fill="none"
           stroke="url(#orbit)" stroke-width="2" stroke-opacity="0.35"
           transform="rotate(15 960 540)"/>

  <path d="M960 320 L985 510 L1180 540 L985 570 L960 760 L935 570 L740 540 L935 510 Z"
        fill="#1A1F2E" opacity="0.85"/>

  <circle cx="820" cy="820" r="6" fill="#0F6FE8"/>
  <circle cx="960" cy="860" r="7" fill="#0F6FE8"/>
  <circle cx="1100" cy="900" r="6" fill="#0F6FE8"/>

  <g fill="#1A1F2E">
    <circle cx="120" cy="180" r="1.5" opacity="0.4"/>
    <circle cx="280" cy="320" r="1" opacity="0.3"/>
    <circle cx="430" cy="100" r="1.5" opacity="0.4"/>
    <circle cx="610" cy="220" r="1" opacity="0.3"/>
    <circle cx="1700" cy="140" r="1.5" opacity="0.4"/>
    <circle cx="1540" cy="300" r="1" opacity="0.3"/>
    <circle cx="1380" cy="100" r="1.5" opacity="0.4"/>
    <circle cx="1800" cy="900" r="1" opacity="0.3"/>
    <circle cx="1600" cy="980" r="1.5" opacity="0.4"/>
    <circle cx="140" cy="900" r="1" opacity="0.3"/>
    <circle cx="240" cy="980" r="1.5" opacity="0.4"/>
  </g>
</svg>
"""


def wallpaper_midnight() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080" width="1920" height="1080">
  <defs>
    <radialGradient id="bg" cx="50%" cy="50%" r="80%">
      <stop offset="0%" stop-color="#080B14"/>
      <stop offset="60%" stop-color="#04060B"/>
      <stop offset="100%" stop-color="#000000"/>
    </radialGradient>
    <radialGradient id="starGlow" cx="50%" cy="40%" r="40%">
      <stop offset="0%" stop-color="#7C5CFF" stop-opacity="0.35"/>
      <stop offset="40%" stop-color="#7C5CFF" stop-opacity="0.10"/>
      <stop offset="100%" stop-color="#7C5CFF" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="orbit" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#7C5CFF" stop-opacity="0.65"/>
      <stop offset="100%" stop-color="#2D7FF9" stop-opacity="0.30"/>
    </linearGradient>
  </defs>

  <rect width="1920" height="1080" fill="url(#bg)"/>
  <rect width="1920" height="1080" fill="url(#starGlow)"/>

  <ellipse cx="960" cy="540" rx="700" ry="200" fill="none"
           stroke="url(#orbit)" stroke-width="2" stroke-opacity="0.55"
           transform="rotate(-15 960 540)"/>
  <ellipse cx="960" cy="540" rx="500" ry="140" fill="none"
           stroke="url(#orbit)" stroke-width="2" stroke-opacity="0.40"
           transform="rotate(15 960 540)"/>

  <path d="M960 320 L985 510 L1180 540 L985 570 L960 760 L935 570 L740 540 L935 510 Z"
        fill="#FFFFFF" opacity="0.95"/>

  <circle cx="820" cy="820" r="6" fill="#7C5CFF"/>
  <circle cx="960" cy="860" r="7" fill="#7C5CFF"/>
  <circle cx="1100" cy="900" r="6" fill="#7C5CFF"/>

  <!-- Brighter star field (OLED-friendly; needs more contrast) -->
  <g fill="#FFFFFF">
    <circle cx="120" cy="180" r="2" opacity="0.9"/>
    <circle cx="280" cy="320" r="1" opacity="0.7"/>
    <circle cx="430" cy="100" r="2" opacity="0.85"/>
    <circle cx="610" cy="220" r="1" opacity="0.6"/>
    <circle cx="1700" cy="140" r="2" opacity="0.85"/>
    <circle cx="1540" cy="300" r="1" opacity="0.6"/>
    <circle cx="1380" cy="100" r="2" opacity="0.85"/>
    <circle cx="1800" cy="900" r="1" opacity="0.7"/>
    <circle cx="1600" cy="980" r="2" opacity="0.9"/>
    <circle cx="140" cy="900" r="1" opacity="0.6"/>
    <circle cx="240" cy="980" r="2" opacity="0.85"/>
    <circle cx="1820" cy="220" r="1" opacity="0.6"/>
    <circle cx="80" cy="640" r="1.5" opacity="0.7"/>
    <circle cx="1850" cy="640" r="1.5" opacity="0.7"/>
    <circle cx="320" cy="640" r="1" opacity="0.5"/>
    <circle cx="1620" cy="640" r="1" opacity="0.5"/>
  </g>
</svg>
"""


def wallpaper_aurora() -> str:
    return """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080" width="1920" height="1080">
  <defs>
    <radialGradient id="bg" cx="50%" cy="60%" r="80%">
      <stop offset="0%" stop-color="#0F2419"/>
      <stop offset="60%" stop-color="#0A1A14"/>
      <stop offset="100%" stop-color="#040A08"/>
    </radialGradient>
    <linearGradient id="aurora" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#2FB57C" stop-opacity="0"/>
      <stop offset="30%" stop-color="#2FB57C" stop-opacity="0.55"/>
      <stop offset="55%" stop-color="#0FB3D9" stop-opacity="0.55"/>
      <stop offset="80%" stop-color="#7C5CFF" stop-opacity="0.45"/>
      <stop offset="100%" stop-color="#7C5CFF" stop-opacity="0"/>
    </linearGradient>
    <radialGradient id="starGlow" cx="50%" cy="40%" r="40%">
      <stop offset="0%" stop-color="#2FB57C" stop-opacity="0.30"/>
      <stop offset="100%" stop-color="#2FB57C" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <rect width="1920" height="1080" fill="url(#bg)"/>
  <rect width="1920" height="1080" fill="url(#starGlow)"/>

  <!-- Aurora bands -->
  <path d="M 0 360 Q 480 280, 960 360 T 1920 360 L 1920 420 Q 1440 360, 960 420 T 0 420 Z"
        fill="url(#aurora)" opacity="0.85"/>
  <path d="M 0 460 Q 480 400, 960 460 T 1920 460 L 1920 520 Q 1440 460, 960 520 T 0 520 Z"
        fill="url(#aurora)" opacity="0.65"/>

  <!-- Star field -->
  <g fill="#FFFFFF">
    <circle cx="120" cy="180" r="1.5" opacity="0.8"/>
    <circle cx="280" cy="220" r="1" opacity="0.5"/>
    <circle cx="430" cy="100" r="1.5" opacity="0.7"/>
    <circle cx="610" cy="160" r="1" opacity="0.5"/>
    <circle cx="1700" cy="140" r="1.5" opacity="0.7"/>
    <circle cx="1540" cy="220" r="1" opacity="0.5"/>
    <circle cx="1380" cy="100" r="1.5" opacity="0.7"/>
    <circle cx="900" cy="80" r="1" opacity="0.5"/>
    <circle cx="1080" cy="60" r="1.5" opacity="0.7"/>
    <circle cx="1820" cy="200" r="1" opacity="0.5"/>
  </g>

  <!-- Central star (lower, after aurora) -->
  <path d="M960 720 L985 870 L1140 900 L985 930 L960 1040 L935 930 L780 900 L935 870 Z"
        fill="#FFFFFF" opacity="0.85"/>

  <circle cx="820" cy="1000" r="4" fill="#2FB57C"/>
  <circle cx="960" cy="1020" r="5" fill="#2FB57C"/>
  <circle cx="1100" cy="1040" r="4" fill="#2FB57C"/>
</svg>
"""


def write_svg(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8")
    print(f"  wrote {path}")


def render_png(svg_path: Path, png_path: Path, width: int, height: int) -> None:
    cairosvg.svg2png(
        bytestring=svg_path.read_bytes(),
        write_to=str(png_path),
        output_width=width,
        output_height=height,
    )
    print(f"  rendered {png_path}")


def main() -> int:
    # 1. Logos
    print("[1/4] Generating logos")
    write_svg(BRANDING_DIR / "orion-logo.svg", orion_logo_svg("dark"))
    write_svg(BRANDING_DIR / "orion-logo-light.svg", orion_logo_svg("light"))
    render_png(BRANDING_DIR / "orion-logo.svg",
               BRANDING_DIR / "orion-logo.png", 256, 256)
    render_png(BRANDING_DIR / "orion-logo-light.svg",
               BRANDING_DIR / "orion-logo-light.png", 256, 256)

    # 2. App icon
    print("[2/4] Generating app icon")
    write_svg(BRANDING_DIR / "orion-icon.svg", orion_icon_svg())
    render_png(BRANDING_DIR / "orion-icon.svg",
               BRANDING_DIR / "orion-icon.png", 256, 256)

    # 3. Boot splash
    print("[3/4] Generating boot splash")
    write_svg(BRANDING_DIR / "orion-boot-splash.svg", orion_boot_splash_svg())
    render_png(BRANDING_DIR / "orion-boot-splash.svg",
               BRANDING_DIR / "orion-boot-splash.png", 1920, 1080)

    # 4. Wallpapers
    print("[4/4] Generating wallpapers")
    wallpapers = [
        ("orion-dark", wallpaper_dark()),
        ("orion-light", wallpaper_light()),
        ("orion-midnight", wallpaper_midnight()),
        ("orion-aurora", wallpaper_aurora()),
    ]
    for name, svg in wallpapers:
        svg_path = WALLPAPERS_DIR / f"{name}.svg"
        png_path = WALLPAPERS_DIR / f"{name}.png"
        write_svg(svg_path, svg)
        render_png(svg_path, png_path, 1920, 1080)

    # 5. Syslinux boot splash (small, for BIOS boot menu)
    print("[5/5] Generating syslinux splash")
    splash_svg = SYSINUX_DIR / "splash.svg"
    splash_png = SYSINUX_DIR / "splash.png"
    splash_content = """<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 480" width="640" height="480">
  <defs>
    <radialGradient id="bg" cx="50%" cy="50%" r="80%">
      <stop offset="0%" stop-color="#131826"/>
      <stop offset="100%" stop-color="#070A12"/>
    </radialGradient>
  </defs>
  <rect width="640" height="480" fill="url(#bg)"/>
  <g transform="translate(320 200)">
    <ellipse cx="0" cy="0" rx="100" ry="40" fill="none" stroke="#2D7FF9" stroke-width="3"
             transform="rotate(-25)"/>
    <path d="M0 -70 L12 -10 L80 0 L12 10 L0 70 L-12 10 L-80 0 L-12 -10 Z" fill="#FFFFFF"/>
    <circle cx="-50" cy="100" r="4" fill="#5C9DFF"/>
    <circle cx="0" cy="115" r="5" fill="#5C9DFF"/>
    <circle cx="50" cy="130" r="4" fill="#5C9DFF"/>
  </g>
  <text x="320" y="340" text-anchor="middle"
        font-family="Inter, sans-serif" font-size="32" font-weight="600"
        letter-spacing="4" fill="#FFFFFF">ORION OS</text>
  <text x="320" y="380" text-anchor="middle"
        font-family="Inter, sans-serif" font-size="14" fill="#7E8699"
        letter-spacing="2">Live / Install Media</text>
</svg>
"""
    write_svg(splash_svg, splash_content)
    render_png(splash_svg, splash_png, 640, 480)

    print("\nAll branding assets generated.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
