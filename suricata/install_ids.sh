#!/usr/bin/env bash
#▶ Active les options strictes :
#   -e : quitte le script à la première erreur
#   -u : erreur si une variable non définie est utilisée
#   -o pipefail : si une étape d’un pipe échoue, le script échoue
set -euo pipefail

echo "➜ Installation Suricata + IDS"
# Met à jour la liste des paquets
sudo apt update
# Installe l’outil pour gérer des PPAs
sudo apt install -y software-properties-common
# Ajoute le PPA officiel de Suricata (version stable)
sudo add-apt-repository -y ppa:oisf/suricata-stable
# Recharge la liste avec le PPA ajouté
sudo apt update
# Installe Suricata et son outil de mise à jour de règles
sudo apt install -y suricata suricata-update

echo "➜ Récupération des règles"
# Télécharge et génère les règles configurées via suricata-update
sudo suricata-update
# Prépare les répertoires pour les règles et les logs IDS
sudo mkdir -p /etc/suricata/rules /var/log/suricata/ids
# Copie la règle Emerging Threats générée vers le dossier de conf
sudo cp /var/lib/suricata/rules/emerging.rules /etc/suricata/rules/

echo "➜ Création du fichier IDS"
# Génère le fichier de configuration suricata-ids.yaml
cat <<'EOF' | sudo tee /etc/suricata/suricata-ids.yaml
%YAML 1.1
---
run-mode: auto   # détecte automatiquement af-packet vs pcap
af-packet:
  - interface: wlp3s0          # interface à écouter (Wi‑Fi ici)
    cluster-id: 99             # ID pour la répartition de flux
    cluster-type: cluster_flow # répartit chaque flux TCP sur un thread
    defrag: yes                # active le défiaçage IP
    use-mmap: yes              # utilise mmap pour la performance
    tpacket-v3: yes            # version 3 du ring buffer
default-log-dir: /var/log/suricata/ids  # répertoire pour logs IDS
default-rule-path: /etc/suricata/rules   # répertoire des règles
rule-files: [ emerging.rules ]           # règles à charger
outputs:
  - fast: { enabled: yes }  # log texte rapide pour débogage
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json   # écrit les alertes JSON ici
      types: [ alert ]     # types d’événements à exporter
EOF

echo "➜ Création du service IDS"
# Crée une unité systemd pour gérer Suricata en mode IDS
sudo tee /etc/systemd/system/suricata-ids.service > /dev/null << 'EOF'
[Unit]
Description=Suricata IDS (AF_PACKET sniffing)
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
# Démarre Suricata avec la conf IDS et crée un PIDfile
ExecStart=/usr/bin/suricata -c /etc/suricata/suricata-ids.yaml --pidfile /run/suricata-ids.pid
# Stoppe Suricata proprement en tuant tous les processus
ExecStop=/usr/bin/killall suricata
Restart=on-failure

[Install]
WantedBy=multi-user.target  # active le service au démarrage multi‑utilisateur
EOF

# Recharge systemd pour prendre en compte le nouveau service
sudo systemctl daemon-reload
# Active et démarre immédiatement le service suricata-ids
sudo systemctl enable --now suricata-ids
