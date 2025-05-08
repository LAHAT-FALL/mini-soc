# Déploiement EveBox

**Décrivant le déploiement EveBox**


**Exemple de docker-compose pour EveBox**

Pour déployer EveBox, l'exemple de docker-compose extrait les événements depuis un fichier `eve.json`, généré par Suricata. Voici un exemple de configuration avec explication de chaque section : les ports, volumes, variables d’environnement et commandes. Ensuite, pour l'interface web : l'interface est accessible via `http://server:5636`, où vous pouvez filtrer, rechercher, taguer et télécharger des pcap. Pas besoin de Docker Compose complexe, juste les services nécessaires.


Réflexion durant 17 secondes


Voici un exemple minimal de **docker‑compose.yml** pour déployer EveBox en mode serveur (IPS/IDS), lire le fichier JSON de Suricata et stocker les événements dans une base embarquée. Ensuite, je détaille chaque section et, enfin, je vous guide dans l’utilisation de l’interface Web.

```yaml
version: '3.8'

services:
  evebox:
    image: jasonish/evebox:latest
    container_name: evebox
    restart: unless-stopped

    # Expose le port web de l’UI EveBox (par défaut 5636)
    ports:
      - "5636:5636"

    # Montez le fichier eve.json produit par Suricata, et un dossier pour la base de données interne
    volumes:
      - ./eve.json:/var/log/suricata/eve.json:ro
      - ./evebox-db:/root/.evebox/db

    # Variables d’environnement pour configurer l’hôte d’écoute de l’UI et le port HTTP
    environment:
      - EVEBOX_UI_HOST=0.0.0.0
      - EVEBOX_HTTP_PORT=5636
      - TZ=Etc/UTC

    # Démarre le serveur en lisant le fichier eve.json à la volée
    command: ["server", "--log-file", "/var/log/suricata/eve.json", "--on-read"]
```

---

## Décryptage du fichier

1. **version**
   Spécifie la version de la syntaxe Docker Compose (ici 3.8).

2. **services › evebox**
   Définit le conteneur qui exécute EveBox (image officielle `jasonish/evebox:latest`).

3. **restart: unless-stopped**
   Redémarre EveBox automatiquement sauf si vous l’arrêtez manuellement.

4. **ports**

   * `5636:5636` : publie le port 5636 du conteneur sur la machine hôte.
     C’est celui de l’interface Web (UI) par défaut.

5. **volumes**

   * `./eve.json:/var/log/suricata/eve.json:ro` :
     lie votre fichier local `eve.json` (issu de Suricata) en lecture seule.
   * `./evebox-db:/root/.evebox/db` :
     conserve l’historique des alertes (base BoltDB) entre les redémarrages.

6. **environment**

   * `EVEBOX_UI_HOST=0.0.0.0` : permet d’accéder à l’UI depuis n’importe quelle IP.
   * `EVEBOX_HTTP_PORT=5636` : redéfinit le port HTTP interne (même que le port exposé).
   * `TZ=Etc/UTC` : optionnel, pour caler la timezone.

7. **command**
   Lance la commande équivalente à :

   ```bash
   evebox server \
     --log-file /var/log/suricata/eve.json \
     --on-read
   ```

   * `server` : démarre le mode serveur+UI
   * `--log-file` : chemin vers `eve.json`
   * `--on-read` : traite les événements au fur et à mesure qu’ils sont écrits

---

## Utilisation de l’interface Web

1. **Accès**
   Ouvrez votre navigateur sur :

   ```
   http://<IP_de_votre_hôte>:5636
   ```

   Vous arrivez sur la page d’accueil de EveBox.

2. **Vue d’ensemble (Dashboard)**

   * **Chronologie** des alertes (histogramme par minute/heure).
   * **Bouton de rafraîchissement** (auto‑refresh possible).
   * **Barre de recherche** libre (Lucene‑style) :

     ```
     alert.signature:"ET SCAN NMAP" AND src_ip:10.0.0.5
     ```

3. **Table des événements**

   * Colonnes par défaut : date/heure, niveau (`info`/`warning`/`critical`), signature, src/dst IP & port.
   * Cliquez sur l’en-tête d’une colonne pour trier.

4. **Filtrage et recherche**

   * **Filtres rapides** par type (HTTP, TLS, DNS, flow, alert).
   * Possibilité de **combiner** conditions (`AND`, `OR`, regex).

5. **Détails d’un événement**
   En cliquant sur une ligne :

   * **Vue JSON brute** de l’événement Suricata.
   * **Payload** extrait (hex/base64) et lien pour **télécharger un pcap** relatif à l’alerte.
   * Informations Suricata (SID, rev, classification, etc.).

6. **Acknowledge & Tagging**

   * **Ack** (coche) pour marquer une alerte comme “traitée”.
   * **Tags** personnalisés (ex. `false-positive`, `triage-important`).
   * **Commentaires** associés à chaque événement.

7. **Export & Reporting**

   * Export CSV des événements filtrés.
   * API REST (documentée) pour extraire les données automatiquement.

8. **Administration**

   * **Paramètres** (roue crantée) pour changer la couleur des niveaux, la pagination, les alertes auto‑rafraîchissantes, etc.
   * **Suppression** manuelle de la base de données (`./evebox-db`) si vous voulez repartir de zéro.

---

> **Conseil rapide :**
> Après toute modification du `docker-compose.yml`, relancez avec :
>
> ```bash
> docker-compose down
> docker-compose up -d
> ```
>
> puis vérifiez les logs :
>
> ```bash
> docker-compose logs -f evebox
> ```
>
> pour vous assurer que EveBox lit bien votre `eve.json`.

Vous êtes maintenant prêt à exploiter EveBox pour visualiser et gérer vos alertes Suricata !
