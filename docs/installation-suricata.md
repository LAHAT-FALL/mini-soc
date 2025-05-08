# Installation de Suricata

**Expliquant l'installation de Suricata**


Voici une procédure pas à pas, avec commentaires, pour installer Suricata (mode IDS/IPS) sur Ubuntu/Debian, ajouter le dépôt PPA, installer les paquets `suricata` et `suricata-update`, puis importer vos règles :

---

## 1. Ajouter le PPA officiel de Suricata

```bash
# Mettre à jour la liste des paquets
sudo apt-get update

# Installer l'outil pour gérer les dépôts tiers
sudo apt-get install -y software-properties-common

# Ajouter le PPA "oisf/suricata-stable" pour toujours avoir la version stable la plus récente
sudo add-apt-repository ppa:oisf/suricata-stable -y

# Rafraîchir à nouveau la liste des paquets pour inclure le nouveau PPA
sudo apt-get update
```

---

## 2. Installer Suricata et l’outil de mise à jour de règles

```bash
# Installer Suricata (le moteur IDS/IPS) et suricata-update (gestionnaire de règles)
sudo apt-get install -y suricata suricata-update

# Vérifier les versions installées
suricata --version        # doit afficher la version de Suricata
suricata-update --version # doit afficher la version de suricata-update
```

---

## 3. Configurer et importer vos règles

Suricata‑update simplifie la récupération et la génération des règles au format natif de Suricata.

```bash
# 3.1 Lister les sources de règles disponibles
suricata-update list-sources
# → Exemples : et/open, et/community, oisf, snort, ...

# 3.2 Activer la source Emerging Threats Open (gratuit)
suricata-update enable-source et/open

# 3.3 (Optionnel) Désactiver les autres sources si non souhaitées
# suricata-update disable-source et/community

# 3.4 Mettre à jour la base des règles (téléchargement + génération)
suricata-update update

# 3.5 Reconstruire les fichiers de règles pour Suricata
suricata-update build

# 3.6 Vérifier que les fichiers .rules ont bien été générés
ls /etc/suricata/rules/*.rules
```

---

## 4. Tester la configuration et les règles

```bash
# Tester votre fichier de conf principal avec règles incluses
sudo suricata -T -c /etc/suricata/suricata.yaml

# Si tout est OK, vous devriez voir "Configuration appears to be OK"
```

---

### Explications

* **software-properties-common**
  Fournit `add-apt-repository` pour ajouter facilement des PPA.

* **ppa\:oisf/suricata-stable**
  PPA maintenu par la communauté OISF pour distribuer les dernières versions stable de Suricata.

* **suricata-update**
  Outil Python qui gère vos sources de règles (Emerging Threats, OISF, etc.), télécharge les dernières règles, les convertit au format Suricata, et les place dans `/etc/suricata/rules/`.

* **enable-source / disable-source**
  Pour choisir quelles collections de règles vous voulez activer (par exemple `et/open` pour Emerging Threats Open).

* **update + build**
  `update` télécharge les règles, `build` génère les fichiers `.rules` finaux.

---

Vous avez maintenant Suricata installé, vos règles à jour, et vous pouvez démarrer Suricata en mode IDS ou IPS selon votre configuration. N’hésitez pas si vous souhaitez approfondir la configuration syslog, EVE JSON ou le mode inline !
