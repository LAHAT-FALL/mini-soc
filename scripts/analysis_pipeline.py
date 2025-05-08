#!/usr/bin/env python3
import pandas as pd
def load_alerts(path="evebox_alerts.csv"):
    return pd.read_csv(path)
def summary_by_src(df):
    return df.groupby("src_ip").size().sort_values(ascending=False)
if __name__ == "__main__":
    df = load_alerts()
    print("Top sources:\n", summary_by_src(df).head(10))
