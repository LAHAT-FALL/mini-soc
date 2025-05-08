#!/usr/bin/env bash
set -euo pipefail
echo "➜ Installation Suricata + IDS"
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:oisf/suricata-stable
sudo apt update
sudo apt install -y suricata suricata-update
echo "➜ Récupération des règles"
sudo suricata-update
sudo mkdir -p /etc/suricata/rules /var/log/suricata/ids
sudo cp /var/lib/suricata/rules/emerging.rules /etc/suricata/rules/
echo "➜ Création du fichier IDS"
cat <<'EOF' | sudo tee /etc/suricata/suricata-ids.yaml
%YAML 1.1
---
run-mode: auto
af-packet:
  - interface: wlp3s0
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
    use-mmap: yes
    tpacket-v3: yes
default-log-dir: /var/log/suricata/ids
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
echo "➜ Création du service IDS"
sudo tee /etc/systemd/system/suricata-ids.service > /dev/null << 'EOF'
[Unit]
Description=Suricata IDS (AF_PACKET sniffing)
After=network-online.target
Wants=network-online.target
[Service]
Type=forking
ExecStart=/usr/bin/suricata -c /etc/suricata/suricata-ids.yaml --pidfile /run/suricata-ids.pid
ExecStop=/usr/bin/killall suricata
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now suricata-ids
