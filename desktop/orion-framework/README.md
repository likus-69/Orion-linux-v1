# orion-framework — shared Qt6 library for Orion desktop components

Orion Framework is the shared Qt6/QML library that every Orion-branded desktop
component depends on. It provides:

- `Orion::Theme` — design tokens, theme manager, accent switching, reduced-motion
- `Orion::Color`, `Orion::Space`, `Orion::Radius`, `Orion::Typography` — token namespaces
- `org.orion.framework.*` QML modules
- Reusable QML components: `OrionButton`, `OrionCard`, `OrionListRow`,
  `OrionTextField`, `OrionComboBox`, `OrionSwitch`, `OrionSlider`,
  `OrionDialog`, `OrionTooltip`, `OrionIcon`
- A small `Orion::Settings` class for reading/writing `~/.config/orion/*.json`
- A `Orion::Log` helper for consistent Qt logging categories

The library is intentionally small. It does NOT pull in KDE Frameworks, so
components that depend on KWin/Plasma APIs must depend on those directly.

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_TESTING=ON
cmake --build build -j$(nproc)
sudo cmake --install build
```

## Run tests

```bash
cd build && ctest --output-on-failure
```

## License

GPL-3.0-or-later. See `LICENSE`.
