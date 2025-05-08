#!/usr/bin/env python3
import requests       # pour faire des requêtes HTTP
import pandas as pd  # pour manipuler les données en tableau
import sys            # pour accéder aux flux d’erreur et contrôler la sortie

# ——— Configuration de l’API EveBox ———
API_URL  = "https://localhost:5636/api/alerts"  # URL de l’endpoint REST d’EveBox
API_USER = "admin"                              # utilisateur pour l’authentification basique
API_PASS = "GDoRZTbWd0Z0"                       # mot de passe associé

# ——— Appel à l’API ———
resp = requests.get(
    API_URL,
    auth=(API_USER, API_PASS),  # passe l’utilisateur et le mot de passe
    verify=False                # désactive la vérification SSL (à éviter en prod)
)

# ——— Gestion des erreurs HTTP ———
if resp.status_code != 200:
    # Affiche un message d’erreur sur stderr et termine avec un code non‑zéro
    print(" EveBox API returned {resp.status_code}", file=sys.stderr)
    sys.exit(1)

# ——— Extraction et normalisation des données ———
alerts = resp.json().get("alerts", [])  # récupère la liste d’alertes depuis le JSON
df     = pd.json_normalize(alerts)      # aplatit les objets JSON en colonnes d’un DataFrame

# ——— Sauvegarde au format CSV ———
df.to_csv("evebox_alerts.csv", index=False)  # exporte le DataFrame sans la colonne d’index

print("Alerts saved to evebox_alerts.csv")

