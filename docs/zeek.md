# NSM avec Zeek

Ce guide détaille l’installation de Zeek, la configuration du fichier **node.cfg** pour un déploiement en cluster léger, et les commandes de déploiement.

---

## 1. Prérequis

* Système Linux (Ubuntu 20.04+ ou Debian 11+).
* Accès `root` ou `sudo`.
* Interface réseau dédiée à la capture (ex. `eth0` ou `ens33`).

## 2. Installation de Zeek

### 2.1 Installer les dépendances

```bash
sudo apt-get update
sudo apt-get install -y \
  cmake make gcc g++ flex bison libpcap-dev libssl-dev \
  python3 python3-dev zlib1g-dev git
```

### 2.2 Installation via dépôt officiel

```bash
# Importer la clé GPG officielle
curl -fsSL https://download.zeek.org/zeek-packages.key | sudo apt-key add -
# Ajouter le dépôt Zeek (ici pour Ubuntu focal)
echo 'deb https://download.zeek.org/debian focal zeek' \
  | sudo tee /etc/apt/sources.list.d/zeek.list
sudo apt-get update
sudo apt-get install -y zeek
```

> **Alternative :** Compiler depuis les sources
>
> ```bash
> wget https://download.zeek.org/zeek-<version>.tar.gz
> tar xzf zeek-<version>.tar.gz && cd zeek-<version>
> ./configure --prefix=/opt/zeek && make -j$(nproc)
> sudo make install
> ```

## 3. Configuration du cluster (`node.cfg`)

Le fichier de configuration cluster se trouve sous `/usr/local/zeek/etc/node.cfg` ou `/opt/zeek/etc/node.cfg` selon votre installation.

```ini
[manager]
type=manager
host=localhost

[logger]
type=logger
host=localhost

[proxy]
type=proxy
host=localhost

[worker-1]
type=worker
host=localhost
interface=eth0

# Pour un second worker (si plusieurs interfaces ou machines) :
#[worker-2]
type=worker
host=remote-host.example.com
interface=eth1
```

* **manager** : coordonne le déploiement et la configuration.
* **logger** : collecte et écrit les journaux (fichiers `.log`).
* **proxy** : répartit le trafic capturé vers les workers.
* **worker** : analyse les paquets sur l’interface spécifiée.

## 4. Déploiement et gestion avec `zeekctl`

1. **Vérifier la configuration :**

   ```bash
   sudo zeekctl check-config
   ```
2. **Installer les scripts sur les nœuds :**

   ```bash
   sudo zeekctl install
   ```
3. **Démarrer le cluster :**

   ```bash
   sudo zeekctl start
   ```
4. **Statut & contrôle :**

   ```bash
   sudo zeekctl status    # État des managers, workers, proxy
   sudo zeekctl stop      # Arrêter le cluster
   sudo zeekctl restart   # Redémarrer après modification
   ```

## 5. Logs et intégration SIEM

* Les journaux sont générés dans `/opt/zeek/logs/current` ou `/var/log/zeek`.
* Utilisez **Filebeat** ou **Winlogbeat** pour importer les logs dans votre SIEM (Elasticsearch, Splunk, etc.).

---

Vous disposez maintenant d’un NSM léger avec Zeek, prêt à capturer et analyser le trafic réseau de votre Mini‑SOC.  !

