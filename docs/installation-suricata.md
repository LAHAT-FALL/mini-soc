# Installation de Suricata

**Expliquant l'installation de Suricata**


**Ajout de Windows aux instructions**


Voici la procédure pour **Windows** en plus de celle pour **Debian/Ubuntu**.


## 1. Sous Debian/Ubuntu

```bash
# 1.1 Mettre à jour et ajouter le PPA
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:oisf/suricata-stable -y
sudo apt-get update

# 1.2 Installer Suricata et suricata-update
sudo apt-get install -y suricata suricata-update
suricata --version
suricata-update --version

# 1.3 Configurer et importer les règles
suricata-update list-sources
suricata-update enable-source et/open
suricata-update update
suricata-update build
ls /etc/suricata/rules/*.rules

# 1.4 Tester la conf
sudo suricata -T -c /etc/suricata/suricata.yaml
```

---

## 2. Sous Windows (10/11 ou Server 2016+)

### 2.1 Prérequis

* Compte Administrateur / PowerShell en mode Administrateur
* (Optionnel) [Chocolatey](https://chocolatey.org/install)

### 2.2 Installer Suricata

**Via Chocolatey**

```powershell
choco install suricata -y
```

**Ou manuellement**

1. Télécharger l’installeur MSI Windows depuis :
   [https://www.openinfosecfoundation.org/download/](https://www.openinfosecfoundation.org/download/) (section “Windows Binaries”)
2. Lancer le `.msi` et suivre l’assistant (par défaut dans `C:\Program Files\Suricata`).

### 2.3 Installer suricata-update

1. Installer **Python 3.8+** depuis python.org ou le Microsoft Store.
2. Vérifier que `python --version` renvoie bien la version installée.
3. Installer suricata-update via pip :

   ```powershell
   pip install suricata-update
   ```
4. S’assurer que le dossier `…\Python3x\Scripts` est dans votre **PATH** pour invoquer `suricata-update`.

### 2.4 Importer et générer les règles

```powershell
# Activer Emerging Threats Open
suricata-update enable-source et/open

# Télécharger et construire
suricata-update update
suricata-update build

# Vérifier que les *.rules sont présents
dir "C:\Program Files\Suricata\rules\*.rules"
```

> **Note** : par défaut, suricata-update va déposer les règles dans `C:\Program Files\Suricata\rules`.

### 2.5 Tester la configuration

```powershell
# Test de la config principale
& "C:\Program Files\Suricata\suricata.exe" -T -c "C:\Program Files\Suricata\suricata.yaml"
```

---

Vous avez désormais, côte‑à‑côte, les instructions pour installer Suricata et suricata-update **sur Linux** et **sur Windows**.
