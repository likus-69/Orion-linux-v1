# Orion Search

Orion OS desktop search indexer (apps, files, settings).

Part of Orion OS. Depends on `orion-framework` and Qt 6 / QML.

## Build

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j$(nproc)
sudo cmake --install build
```

The binary installs to `/usr/lib/orion/orion-search`.

## Known limitations

- **NOT compiled in the sandbox** (no Qt6 / cmake available).
  Build on a real Arch Linux host with `orion-framework` installed.
- See `STATUS.md` at the repository root for the current
  implementation state.

## License

GPL-3.0-or-later. See `LICENSE` at the repository root.
