# Mini‑SOC à la maison

Un **Mini‑SOC** (teaching SOC fundamentals) te permet de recréer chez toi les principaux jalons d’un Security Operations Center :

1. **IDS passif** avec Suricata (AF_PACKET)  
2. **IPS inline** avec Suricata (NFQUEUE)  
3. **Visualisation et gestion d’alertes** avec EveBox (Docker)  
4. **Network Security Monitoring (NSM)** avec Zeek  
5. **Extraction et analyse** automatisée via Python  

---

## 🎯 Objectifs pédagogiques

- Installer, configurer et déployer un IDS/IPS  
- Comprendre la structure et les outputs de Suricata (`fast.log`, `eve.json`)  
- Lancer une interface web d’alerting (EveBox) en conteneur  
- Ajouter une couche NSM pour journaliser en profondeur le trafic (Zeek)  
- Écrire des scripts Python pour extraire, enrichir et analyser les alertes  
- Scripter et automatiser l’ensemble avec des services systemd et Docker

---

## 🚀 Installation & déploiement rapide

### 1. IDS passif

```bash
cd suricata
chmod +x install_ids.sh
sudo ./install_ids.sh
```

### 2. IPS inline

```bash
cd suricata
chmod +x install_ips.sh
sudo ./install_ips.sh
```

### 3. EveBox (alerting web)

```bash
cd evebox
docker-compose up -d
```

### 4. NSM avec Zeek

```bash
cd zeek
chmod +x zeek.init.sh
sudo ./zeek.init.sh
sudo zeekctl deploy
```

### 5. Extraction & analyse Python

```bash
cd scripts
python3 fetch_evebox_alerts.py
python3 analysis_pipeline.py
```

### 6. Tests unitaires

```bash
cd tests
pytest
```
