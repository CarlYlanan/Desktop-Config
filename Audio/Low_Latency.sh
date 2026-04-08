#!/bin/bash

mkdir -p ~/.config/pipewire/pipewire.conf.d/

cat << EOF > ~/.config/pipewire/pipewire.conf.d/99-low-latency.conf
context.properties = {
    default.clock.rate          = 48000
    default.clock.allowed-rates  = [ 44100 48000 ]
    default.clock.quantum       = 64
    default.clock.min-quantum   = 32
    default.clock.max-quantum   = 128
}
EOF

systemctl --user restart pipewire pipewire-pulse wireplumber
