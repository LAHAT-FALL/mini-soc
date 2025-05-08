# Introduction au Mini‑SOC

Un **SOC** (Security Operations Center) est une entité dédiée à la surveillance, la détection, l’analyse et la réponse aux incidents de sécurité au sein d’un réseau ou d’une infrastructure informatique. Traditionnellement déployés au sein d’organisations de grande taille, les SOC centralisent les journaux et événements de sécurité, corrèlent les informations, génèrent des alertes et organisent le processus de traitement des incidents.

Ce **Mini‑SOC** a pour vocation de reproduire, à échelle réduite, les principales fonctionnalités d’un SOC professionnel, afin de :

* **Comprendre les principes fondamentaux** du monitoring et de la réponse à incident.
* **Apprendre à déployer et configurer** des outils open‑source (Suricata, Zeek, Filebeat, ELK/Wazuh, EveBox…).
* **Simuler des scénarios d’attaque et d’incident** sur un réseau local.
* **Mettre en place un workflow complet**, de la collecte de logs à la génération de rapports d’incident.

## Objectifs pédagogiques

1. Installer et configurer un IDS/IPS (Suricata) et un Network Security Monitor (Zeek).
2. Déployer un pipeline de collecte (Filebeat/Winlogbeat) et un SIEM léger (ELK ou Wazuh).
3. Visualiser et traiter les alertes via une interface web (Kibana, EveBox).
4. Simuler des attaques courantes (brute‑force SSH, scan de ports, exploits simples) et analyser les journaux générés.
5. Écrire un rapport d’incident structuré, avec diagrams, timeline et recommandations.

## Aperçu du guide

Le projet se déroule en **5 étapes clés** :

1. **Préparation de l’environnement** : réseau local, VMs/containers, plan d’adressage.
2. **Détection réseau** : installation de Suricata (mode IDS/IPS) et Zeek.
3. **Collecte et ingestion** : configuration de Filebeat/Winlogbeat et du SIEM.
4. **Visualisation & alerting** : déploiement de Kibana, EveBox ou interface Wazuh.
5. **Scénarios et reporting** : exécution d’attaques, analyse des alertes et rédaction d’un rapport final.

Chaque section propose des instructions détaillées, des commandes précises, ainsi que des conseils de tuning et de bonnes pratiques. À la fin de ce guide, vous disposerez d’un laboratoire complet de type SOC Niveau 1, prêt à surveiller et analyser votre réseau personnel.

---

