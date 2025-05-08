# Configuration Suricata IPS

**Explication de la configuration Suricata IPS et NFQUEUE**


**Configuration IPS Suricata et NFQUEUE**

Je vais présenter un extrait de configuration du fichier suricata-ips.yaml, en mettant l'accent sur NFQUEUE et sa configuration pour Suricata en mode IPS (inline). Voici un exemple de la configuration de NFQUEUE :

```yaml
nfqueue:
  - id: 0
    threads: 4
    fail-open: yes
    bypass: no
    cluster-type: cluster_flow
    cluster-id: 99
    defrag: yes
```

Dans Suricata, la section "AF-PACKET" est remplacée par NFQUEUE, et certains paramètres comme "fail-open", "bypass", et "checksum-checks" sont spécifiés pour un traitement en ligne des paquets dans Suricata.


Réflexion durant 20 secondes


Voici une vue typique d’un **suricata-ips.yaml** (la version de Suricata configurée pour fonctionner en mode IPS inline via Netfilter NFQUEUE), avec focus sur la section **nfqueue**.

---

```yaml
##=======================##
## Global vars & paths  ##
##=======================##
vars:
  address-groups:
    HOME_NET: "[192.168.1.0/24]"
    EXTERNAL_NET: "![192.168.1.0/24]"
  port-groups:
    HTTP_PORTS: "[80,443]"

# (… autres sections identiques à suricata.yaml …)

##=======================##
## Mode inline / IPS     ##
##=======================##
# Active le traitement des paquets en mode inline (IPS)
stream:
  tcp:
    enabled: yes
    checksum-validation: yes
    inline: yes      # << passe Suricata en mode IPS

##=======================##
## Capture Netfilter    ##
##=======================##
# Désactive les autres capteurs (af-packet, pcap…) et utilise NFQUEUE
capture:
  # - af-packet: …
  - type: nfqueue

nfqueue:
  - id: 0                # Numéro de la queue Netfilter (iptables -j NFQUEUE --queue-num 0)
    threads: auto        # Nombre de threads de traitement (auto = nombre de cœurs)
    defrag: yes          # Activer le défiaçage IP avant détection
    checksum-checks: yes # Vérifier checksums IP/TCP/UDP
    copy-mode: ips       # Mode copie : 'ips' pour drop/inject, vs 'passthrough' ou 'copy'
    copy-range: 0        # Taille du payload copié (0 = entier)
    fail-open: yes       # Si Suricata plante, laisse passer le trafic (fail‑open)
    bypass: no           # Si queue saturée, ne pas bypass (bloque si Suricata ne répond pas)

##=======================##
## Détection & règles   ##
##=======================##
detect-engine:
  enabled: yes
  thread-ratio: 0.5
  pattern-match-engine: auto

rule-files:
  - /etc/suricata/rules/suricata.rules

##=======================##
## EVE JSON & alerts    ##
##=======================##
eve-log:
  enabled: yes
  filetype: regular
  filename: /var/log/suricata/eve.json
  types:
    - alert
    - http
    - dns
```

---

### Explication détaillée de la section **nfqueue**

| Option              | Description                                                                                                                         |
| ------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **id**              | Numéro de la queue Netfilter (NFQUEUE). Correspond au paramètre `--queue-num` des règles iptables.                                  |
| **threads**         | Nombre de threads qui traiteront les paquets. `auto` utilise tous les cœurs disponibles, ou vous pouvez fixer une valeur (ex. `4`). |
| **defrag**          | Active le défiaçage IP en amont, nécessaire pour analyser correctement des paquets fragmentés.                                      |
| **checksum-checks** | Vérifie la validité des checksums IP/TCP/UDP avant analyse. Si `no`, les paquets avec checksum invalide sont analysés quand même.   |
| **copy-mode**       | Mode de copie dans la queue :                                                                                                       |

* `ips` : Suricata reçoit le paquet complet et peut décider de le DROP ou l’INJECTER (mode IPS).
* `passthrough` : copie uniquement, pas de blocage.
* `copy` / `inline` : selon versions. |
  \| **copy-range**     | Nombre d’octets du payload à copier dans Suricata. `0` = copie l’intégralité (requis en IPS).                                                           |
  \| **fail-open**      | Si Suricata se termine ou ne répond plus, laisse passer tout le trafic (évite de bloquer tout le réseau).                                                |
  \| **bypass**         | En cas de saturation (queue pleine),
* `yes` : bypass automatique (le trafic contourne Suricata),
* `no`  : bloque jusqu’à ce que Suricata consomme la queue.                                         |

---

#### Mise en place iptables

Pour intercepter le trafic en mode IPS, ajoutez par exemple :

```bash
# Trafic transitant par la machine (router)
iptables -I FORWARD -j NFQUEUE --queue-num 0

# Si Suricata est sur l’hôte final
iptables -I INPUT   -j NFQUEUE --queue-num 0
iptables -I OUTPUT  -j NFQUEUE --queue-num 0
```

---

⚙️ **Conseils**

1. **Tester la config** avant passage en production :

   ```bash
   suricata -T -c /etc/suricata/suricata-ips.yaml --af-packet=none
   ```
2. Démarrez Suricata en mode root ou avec capacités Netfilter (`setcap cap_net_raw,cap_net_admin=eip /usr/bin/suricata`).
3. Surveillez la saturation de la queue (`nfq-stat -q 0`) pour ajuster `threads` et `copy-range`.

Vous voilà prêt à faire tourner Suricata en **IPS** avec NFQUEUE 
