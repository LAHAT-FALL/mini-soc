#!/usr/bin/env python3
import requests, pandas as pd, sys
API_URL = "https://localhost:5636/api/alerts"
API_USER = "admin"
API_PASS = "GDoRZTbWd0Z0"
resp = requests.get(API_URL, auth=(API_USER,API_PASS), verify=False)
if resp.status_code != 200:
    print(f"❌ EveBox API returned {resp.status_code}", file=sys.stderr)
    sys.exit(1)
alerts = resp.json().get("alerts", [])
df = pd.json_normalize(alerts)
df.to_csv("evebox_alerts.csv", index=False)
print("✅ Alerts saved to evebox_alerts.csv")
