#!/usr/bin/env bash
set -e

echo "=== Targeted Audio Master Script (Fosi Low-Latency + G560 Fix) ==="

# ---- 1. Realtime Permissions ----
echo "[1/4] Updating realtime limits..."
sudo tee /etc/security/limits.d/99-audio.conf >/dev/null <<'EOF'
@audio   -  rtprio      95
@audio   -  memlock    unlimited
EOF
sudo usermod -aG audio "$USER"

# ---- 2. PipeWire Engine Config ----
echo "[2/4] Writing global PipeWire engine settings..."
mkdir -p ~/.config/pipewire/pipewire.conf.d
cat > ~/.config/pipewire/pipewire.conf.d/10-lowlatency.conf <<'EOF'
context.properties = {
    default.clock.rate          = 48000
    default.clock.allowed-rates = [ 44100 48000 ]
    default.clock.quantum       = 64
    default.clock.min-quantum   = 32
    default.clock.max-quantum   = 256
}
EOF

# ---- 3. Targeted WirePlumber Rules (The 'Hotswap' & 'Fix' Logic) ----
echo "[3/4] Writing device-specific hardware rules..."
mkdir -p ~/.config/wireplumber/wireplumber.conf.d

cat > ~/.config/wireplumber/wireplumber.conf.d/10-targeted-audio.conf <<'EOF'
monitor.alsa.rules = [
  {
    # TARGET: Fosi Audio K5 Pro
    # Keeps your original 0-latency gaming settings
    matches = [ { device.name = "~alsa_card.usb-0c76_Fosi_Audio_K5_Pro*" } ]
    actions = {
      update-props = {
        audio.rate = 48000
        audio.quantum = 64
        api.alsa.period-size = 64
        api.alsa.headroom = 0
      }
    }
  },
  {
    # TARGET: Logitech G560
    # Fixes volume dive and playback silence, enables hotswap
    matches = [ { device.name = "~alsa_card.usb-Logitech_G560_Gaming_Speaker*" } ]
    actions = {
      update-props = {
        api.alsa.soft-mixer = true
        session.suspend-timeout-seconds = 0
        device.profile = "stereo-fallback"
        priority.driver = 1000
        priority.session = 1000
        api.alsa.period-size = 256
        api.alsa.headroom = 512
      }
    }
  }
]
EOF

# ---- 4. Clean Slate & Restart ----
echo "[4/4] Restarting audio with fresh state..."
rm -rf ~/.local/state/wireplumber/*
rm -rf ~/.local/state/pipewire/*

systemctl --user restart pipewire pipewire-pulse wireplumber

echo "-------------------------------------------------------"
echo "Done! Fosi is still fast, G560 is now fixed and hotswappable."
echo "Final reminder: Open 'alsamixer' (F6 -> G560) and set it to 100% once."
