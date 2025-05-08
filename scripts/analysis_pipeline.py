#!/usr/bin/env python3
import pandas as pd  # pandas permet de manipuler facilement des tableaux de données

def load_alerts(path="evebox_alerts.csv"):
    """
    Charge le fichier CSV d'alertes EveBox et renvoie un DataFrame pandas.
    
    :param path: chemin vers le CSV contenant les alertes
    :return: pandas.DataFrame
    """
    # pd.read_csv lit le fichier CSV et convertit chaque colonne en une série pandas
    return pd.read_csv(path)

def summary_by_src(df):
    """
    Regroupe les alertes par adresse source ('src_ip'), compte leur nombre,
    puis trie par ordre décroissant pour identifier les IP les plus actives.
    
    :param df: DataFrame pandas avec au moins une colonne 'src_ip'
    :return: Série pandas indexée par 'src_ip' avec le compte des occurrences
    """
    # df.groupby("src_ip") crée un groupe pour chaque valeur unique de src_ip
    # .size() compte le nombre de lignes dans chaque groupe
    # .sort_values(ascending=False) trie du plus grand au plus petit
    return df.groupby("src_ip").size().sort_values(ascending=False)

if __name__ == "__main__":
    # Ce bloc ne s'exécute que si le script est lancé directement, pas lors d'un import
    # Chargement des données depuis le CSV
    df = load_alerts()
    
    # Calcul du top 10 des adresses source
    top_sources = summary_by_src(df).head(10)
    
    # Affichage formaté du résultat
    print("Top sources:\n", top_sources)



