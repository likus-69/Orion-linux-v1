# /etc/wireplumber/main.lua.d/50-orion-defaults.lua
# Orion default WirePlumber configuration: modest defaults that work for
# most users; advanced users can override via ~/.config/wireplumber/.

-- Use a real-time priority for the audio thread (requires rtkit).
alsa_monitor.enabled = true
bluez_monitor.enabled = true
v4l2_monitor.enabled = true

-- Disable Bluetooth A2DP duplex by default; users can opt in if they need
-- the microphone profile for their headphones.
bluez_monitor.properties = {
  ["bluez5.enable-sbc-xq"] = true,
  ["bluez5.enable-msbc"] = true,
  ["bluez5.enable-hw-volume"] = true,
}

-- Default sample rate; WirePlumber will negotiate this per-stream.
default_audio.properties = {
  ["default.clock.rate"] = 48000,
  ["default.clock.quantum"] = 1024,
  ["default.clock.min-quantum"] = 32,
}
