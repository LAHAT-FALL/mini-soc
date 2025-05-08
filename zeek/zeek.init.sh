#!/usr/bin/env bash
# ▶ Utilise bash et s’assure que le script échoue en cas d’erreur

sudo apt update
# ▶ Met à jour la liste des paquets disponibles

sudo apt install -y zeek
# ▶ Installe Zeek (le moteur NSM) sans demander de confirmation

sudo sed -i 's/interface=.*/interface=wlp3s0/' /opt/zeek/etc/node.cfg
# ▶ Remplace la ligne « interface=… » dans node.cfg
#    pour que Zeek écoute sur votre interface Wi‑Fi (wlp3s0)

sudo zeekctl deploy
# ▶ Déploie la configuration Zeek :
#    • installe les fichiers dans le workdir (~ /opt/zeek)
#    • initialise la base de données d’état
#    • génère les scripts de lancement pour chaque nœud

