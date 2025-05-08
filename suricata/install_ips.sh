#!/usr/bin/env bash
# ▶ Exit on error, undefined variable or failed pipe
set -euo pipefail

echo "➜ Configuration IPS (NFQUEUE)"
# ▶ Crée les répertoires pour les logs IPS et les règles Suricata
sudo mkdir -p /var/log/suricata/ips /etc/suricata/rules

# ▶ Génére le fichier de configuration IPS
cat <<'EOF' | sudo tee /etc/suricata/suricata-ips.yaml
%YAML 1.1
---
run-mode: nfqueue            # Utilise NFQUEUE en mode inline (IPS)
nfqueue:
  - id: 0                    # Numéro de la queue Netfilter à consommer
    bypass: no               # Ne pas contourner Suricata si queue saturée
    fail-open: yes           # Laisser passer le trafic si Suricata plante
    batch-size: 512          # Nombre de paquets lus en une seule fois
default-log-dir: /var/log/suricata/ips
default-rule-path: /etc/suricata/rules
rule-files: [ emerging.rules ]  # Charge le fichier emerging.rules
outputs:
  - fast: { enabled: yes }      # Log texte rapide
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json        # Génère le JSON des alertes
      types: [ alert ]
EOF

# ▶ Intercepte tout le trafic entrant et sortant via NFQUEUE n°0
sudo iptables -I INPUT  -j NFQUEUE --queue-num 0
sudo iptables -I OUTPUT -j NFQUEUE --queue-num 0

# ▶ Crée le service systemd pour gérer Suricata en mode IPS
sudo tee /etc/systemd/system/suricata-ips.service > /dev/null << 'EOF'
[Unit]
Description=Suricata IPS (NFQUEUE)
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
# Démarre Suricata avec la conf IPS et l’option --nfqueue
ExecStart=/usr/bin/suricata \
  -c /etc/suricata/suricata-ips.yaml \
  --pidfile /run/suricata-ips.pid \
  --nfqueue
# Stoppe tous les processus Suricata
ExecStop=/usr/bin/killall suricata
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# ▶ Recharge systemd et active/démarre le service suricata-ips
sudo systemctl daemon-reload
sudo systemctl enable --now suricata-ips
