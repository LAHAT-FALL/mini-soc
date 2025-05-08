#!/usr/bin/env bash
set -euo pipefail
echo "➜ Configuration IPS (NFQUEUE)"
sudo mkdir -p /var/log/suricata/ips /etc/suricata/rules
cat <<'EOF' | sudo tee /etc/suricata/suricata-ips.yaml
%YAML 1.1
---
run-mode: nfqueue
nfqueue:
  - id: 0
    bypass: no
    fail-open: yes
    batch-size: 512
default-log-dir: /var/log/suricata/ips
default-rule-path: /etc/suricata/rules
rule-files: [ emerging.rules ]
outputs:
  - fast: { enabled: yes }
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
      types: [ alert ]
EOF
sudo iptables -I INPUT  -j NFQUEUE --queue-num 0
sudo iptables -I OUTPUT -j NFQUEUE --queue-num 0
sudo tee /etc/systemd/system/suricata-ips.service > /dev/null << 'EOF'
[Unit]
Description=Suricata IPS (NFQUEUE)
After=network-online.target
Wants=network-online.target
[Service]
Type=forking
ExecStart=/usr/bin/suricata -c /etc/suricata/suricata-ips.yaml --pidfile /run/suricata-ips.pid --nfqueue
ExecStop=/usr/bin/killall suricata
Restart=on-failure
[Install]
WantedBy=multi-user-target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now suricata-ips
