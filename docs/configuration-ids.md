**Explication de suricata-ids.yaml**

**Organisation de la réponse sur le fichier `suricata-ids.yaml`**

Je vais structurer l'explication en utilisant des titres en *markdown* pour chaque section importante du fichier. L'utilisateur apprécie les détails techniques et pratiques, alors je vais couvrir des aspects comme :

* **Variables** (`vars:`)
* **Journalisation** (`logging:`)
* **Statistiques** (`stats:`)
* **Capture** (`af-packet:`, `pfring:`, `nfqueue:`, `pcap:`)
* **Réglages réseau** (`host-os-policy:`)
* Plus d'autres sections techniques.

Chaque section aura un résumé et quelques exemples pour préciser les paramètres clés.


Réflexion durant 13 secondes


Voici un tour d’horizon section par section d’un fichier **suricata-ids.yaml** (le fichier de configuration principal de Suricata), avec pour chaque bloc les paramètres clés et leur rôle.

---

## 1. Variables globales (`vars:`)

Définissent les plages réseau et chemins utilisés par les règles et la capture.

```yaml
vars:
  address-groups:
    HOME_NET: "[192.168.1.0/24]"
    EXTERNAL_NET: "![192.168.1.0/24]"
  port-groups:
    HTTP_PORTS: "[80,443]"
    SHELLCODE_PORTS: "![[0:1023]]"
```

* **HOME\_NET** : votre réseau interne (ex. `192.168.1.0/24`).
* **EXTERNAL\_NET** : tout le reste (par défaut la négation de HOME\_NET).
* **port-groups** : regroupe des ports (utile pour cibler certaines règles).

---

## 2. Journalisation (`logging:`)

Paramètres des logs internes de Suricata.

```yaml
logging:
  default-log-level: info
  outputs:
    - console:
        enabled: yes
    - file:
        enabled: yes
        filename: /var/log/suricata/suricata.log
```

* **default-log-level** : niveau de verbosité (`emerg`, `alert`, `error`, `warning`, `info`, `debug`).
* **outputs.console** : affichage sur stdout (bon pour tests).
* **outputs.file** : écrit le log principal (erreurs, warn) dans `suricata.log`.

---

## 3. Statistiques et statistiques état (`stats:`)

Génération périodique de métriques.

```yaml
stats:
  enabled: yes
  # intervalle en secondes
  interval: 60
  outputs:
    - file:
        enabled: yes
        filename: /var/log/suricata/stats.log
```

* **interval** : fréquence d’écriture des compteurs (paquets capturés, évènements détectés…).
* **stats.outputs** : où et comment exporter (fichier, console, unix-socket).

---

## 4. Capture de paquets

### 4.1 AF-Packet (Linux hautes-perfs)

```yaml
af-packet:
  - interface: eth0
    threads: 4
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
    use-mmap: yes
    ring-size: 200000
```

* **interface** : interface réseau à écouter.
* **threads** : nombre de threads de capture (doit correspondre à `cluster-type`).
* **cluster-type** : `cluster_flow` (répartit les flux TCP sur tous les threads).
* **defrag** : activation du défiaçage IP matériel.
* **use-mmap** : capture via mémoire partagée pour la performance.
* **ring-size** : taille du buffer (augmente la résilience en cas de pic de trafic).

### 4.2 Autres méthodes

* **pfring** : si vous utilisez PF\_RING.
* **nfqueue** : pour capturer via Netfilter queue.
* **pcap** : lecture de fichiers pcap ou capture basique.

---

## 5. Décodage et réassemblage réseau

```yaml
defrag:
  memcap: 64mb
  prealloc: yes

stream:
  memcap: 512mb
  tcp:
    enabled: yes
    checksum-validation: yes
    inline: no
```

* **defrag.memcap** : mémoire max pour défiaçage IP.
* **stream.memcap** : mémoire max pour réassemblage TCP.
* **tcp.checksum-validation** : vérifie la validité des checksums.
* **stream.inline** : si Suricata est en mode inline (IPS), active l’injection de paquets.

---

## 6. Analyse applicative (`app-layer:`)

Configure les parseurs de protocoles (HTTP, TLS, DNS…).

```yaml
app-layer:
  protocols:
    http:
      enabled: yes
      libhtp-default-config: yes
      request-body-limit: 10mb
    tls:
      enabled: yes
```

* **http.enabled** : active la décodification HTTP, extraction de headers et bodies.
* **request-body-limit** : taille max du body analysé.
* **tls.enabled** : décodage SSL/TLS pour repérer des anomalies dans le handshake.

---

## 7. Moteur de détection (`detect-engine:`)

Paramètres de l’analyse des règles.

```yaml
detect-engine:
  enabled: yes
  # mode single ou multi-thread
  thread-ratio: 1.0
  # choix du moteur AC automatique
  pattern-match-engine: auto
```

* **thread-ratio** : proportion de threads CPU alloués à la détection.
* **pattern-match-engine** : `auto`, `hyperscan`, ou `classic`. Hyperscan est plus rapide sur des CPU récents.

---

## 8. Gestion des règles

```yaml
rule-files:
  - /etc/suricata/rules/suricata.rules
rule-path: /etc/suricata/rules
```

* **rule-files** : liste des fichiers de règles à charger (ETOpen, Emerging Threats…).
* **rule-path** : chemin racine pour `include` dans les règles.

---

## 9. Classification et références

```yaml
classification:
  file: classification.config

reference:
  file: reference.config
```

* **classification.config** : mappe chaque SID/rule à un niveau de gravité `(e.g. attempt, drop, etc.)`.
* **reference.config** : définit comment enrichir les alertes avec des URL externes (CVE, WASC).

---

## 10. Seuils et filtrage d’événements

```yaml
threshold:
  - track: by_src
    count: 10
    seconds: 60
    action: limit
```

* **track** : par source (`by_src`) ou par flux (`by_flow`).
* **count/seconds** : nombre max d’alertes avant d’appliquer **action** (`limit`, `both`, `ignore`).

---

## 11. Sortie des alertes

### 11.1 Alertes texte

```yaml
alert:
  enabled: yes
  # fichier de log des alertes
  filename: /var/log/suricata/alerts.log
```

* **alert.filename** : où écrire les alertes au format classique (un alert par ligne).

### 11.2 EVE JSON (recommandé)

```yaml
eve-log:
  enabled: yes
  filetype: regular
  filename: /var/log/suricata/eve.json
  types:
    - alert:
        payload: yes
        pcap-file: yes
    - http:
    - dns:
    - tls:
    - flow:
```

* **eve.json** : format JSON unifié, facile à ingérer dans ELK, Splunk, Zeek.
* **types** : liste des catégories d’événements à exporter (alert/http/dns/tls/flow/etc.).
* **payload** : inclusion du payload en base64.
* **pcap-file** : extrait de la trame réseau dans un fichier pcap distinct.

---

## 12. Modules additionnels

* **file-store** : pour sauvegarder en continu les fichiers téléchargés via HTTP/FTP.
* **log-proto** : logs détaillés par protocole (HTTP, TLS, DNS).
* **host-os-policy** / **host-event** : corrélation entre événements et politique OS (audit de fichiers, etc.).

---

### Conseils pratiques

* **Adapter `HOME_NET`** dès le déploiement pour éviter un flot d’alertes internes.
* **Ajuster les threads** de capture / détection selon votre CPU et débit réseau.
* **Limiter la taille des corps HTTP** pour réduire l’usage mémoire.
* **Activer EVE JSON** pour intégration avec vos outils de visualisation.
* **Tester vos règles** après chaque modification de config :

  ```bash
  suricata -T -c /etc/suricata/suricata-ids.yaml
  ```

Avec cette vue détaillée, vous pouvez ajuster chaque section pour optimiser Suricata en fonction de votre environnement et de vos objectifs (IDS pur, mode inline IPS, intégration SIEM, etc.).
