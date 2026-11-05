# Orion Welcome Center

First-run welcome experience for Orion OS. Launches automatically on first
login after install, walks the user through 13 steps:

0. Welcome
1. Navigation tutorial
2. Personalization quick pick (theme + accent)
3. Network setup (Wi-Fi connect)
4. Audio test
5. Display check
6. Hardware scan (NVIDIA/Broadcom detection)
7. Software Center intro
8. Update configuration
9. Backup recommendations
10. Privacy + security (telemetry OFF by default)
11. Documentation + community links
12. Done

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j$(nproc)
sudo cmake --install build
```

## Behavior

- Auto-launches on first login (no `~/.local/state/orion/welcome.done` marker).
- On dismiss, optionally writes the marker so it doesn't auto-launch next time.
- Skippable at every step.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
