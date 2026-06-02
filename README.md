# 🧹 Licenciements Tech — Nettoyage & Analyse Exploratoire avec MySQL

Un projet MySQL complet de bout en bout, basé sur un jeu de données réel de **2 361 licenciements** dans le secteur technologique entre 2020 et 2023. Le projet se déroule en deux phases : nettoyage des données puis analyse exploratoire, entièrement réalisées en SQL.

---

## 📊 Présentation du jeu de données

| Colonne | Description |
|---|---|
| `company` | Nom de l'entreprise |
| `location` | Ville concernée |
| `industry` | Secteur d'activité |
| `total_laid_off` | Nombre d'employés licenciés |
| `percentage_laid_off` | Part de l'effectif licencié (0 à 1) |
| `date` | Date de l'annonce |
| `stage` | Stade de financement (Seed, Série A/B/C, Post-IPO…) |
| `country` | Pays de l'entreprise |
| `funds_raised_millions` | Fonds levés au total (en millions USD) |

---

## 🔧 Phase 1 — Nettoyage des données (`Cleaning_data.sql`)

Les données brutes contenaient plusieurs problèmes traités étape par étape :

### 1. Table de staging
Une table de staging (`layoff_staging`) a été créée pour préserver les données originales intactes tout au long du processus.

### 2. Suppression des doublons
Les doublons ont été identifiés avec `ROW_NUMBER()` et `PARTITION BY` sur l'ensemble des colonnes pertinentes, puis supprimés depuis une seconde table de staging (`layoff_staging1`).

```sql
WITH duplicate_cte AS (
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY company, location, industry, total_laid_off,
      percentage_laid_off, date, stage, country, funds_raised_millions
    ) AS row_num
  FROM layoff_staging
)
SELECT * FROM duplicate_cte WHERE row_num > 1;
```

### 3. Standardisation des données
- **Noms d'entreprises** : espaces en début/fin supprimés avec `TRIM()`
- **Secteur d'activité** : variantes comme `Crypto Currency`, `CryptoCurrency` unifiées en `Crypto`
- **Pays** : points parasites supprimés (`United States.` → `United States`)
- **Villes** : problèmes d'encodage corrigés (`DÃ¼sseldorf` → `Dusseldorf`, etc.)
- **Colonne date** : convertie de `TEXT` vers le type `DATE` avec `STR_TO_DATE()`

### 4. Gestion des valeurs nulles
- Les chaînes vides dans `industry` ont été remplacées par `NULL`
- Les valeurs manquantes ont été reconstituées par auto-jointure sur le nom de l'entreprise
- Les lignes où `total_laid_off` ET `percentage_laid_off` sont toutes les deux `NULL` ont été supprimées (lignes inexploitables)

### 5. Nettoyage final
La colonne utilitaire `row_num` a été supprimée après la déduplication.

---

## 🔍 Phase 2 — Analyse Exploratoire (`Exploratory_data_analysis.sql`)

### Statistiques descriptives
Calcul des valeurs `MAX`, `MIN` et `AVG` sur `total_laid_off`, `percentage_laid_off` et `funds_raised_millions`.

### Entreprises ayant licencié 100 % de leurs effectifs
```sql
SELECT * FROM layoff_staging1
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
```
Certaines de ces entreprises avaient levé des centaines de millions avant de fermer complètement.

### Top entreprises par volume de licenciements
```sql
SELECT company, SUM(total_laid_off)
FROM layoff_staging1
GROUP BY company
ORDER BY 2 DESC;
```

### Licenciements par secteur
Total des licenciements agrégé par secteur pour identifier les industries les plus touchées.

### Licenciements par pays (Top 10)
```sql
SELECT country, SUM(total_laid_off)
FROM layoff_staging1
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;
```

### Évolution dans le temps
- **Par année** : totaux annuels pour observer les grandes tendances
- **Par mois** : totaux mensuels pour identifier les variations saisonnières

### Total cumulé mensuel (Rolling Total)
Somme cumulative des licenciements dans le temps, calculée avec une fonction fenêtre :

```sql
WITH rolling_total AS (
  SELECT SUBSTRING(date, 1, 7) AS mois, SUM(total_laid_off) AS tot_off
  FROM layoff_staging1
  WHERE SUBSTRING(date, 1, 7) IS NOT NULL
  GROUP BY mois
  ORDER BY mois
)
SELECT mois, tot_off,
  SUM(tot_off) OVER(ORDER BY mois) AS total_cumulatif
FROM rolling_total;
```

### Top 5 entreprises par année
Utilisation de `DENSE_RANK()` avec partition par année pour classer les entreprises, puis filtrage sur les 5 premières de chaque année.

---

## 🛠️ Outils utilisés

- **MySQL 8.0** — toutes les requêtes et fonctions fenêtres
- **MySQL Workbench** — exécution des requêtes et visualisation des résultats

---

## 🚀 Comment exécuter le projet

1. Importer `layoffs.csv` dans une base de données MySQL sous le nom de table `layoffs`
2. Exécuter `Cleaning_data.sql` pour produire la table nettoyée `layoff_staging1`
3. Exécuter `Exploratory_data_analysis.sql` pour explorer les données

---

## 💡 Principaux enseignements

- Les **États-Unis** représentent la grande majorité des licenciements recensés
- Les secteurs **Consumer** et **Retail** figurent parmi les plus touchés
- Une forte accélération des licenciements est visible à partir de **fin 2022 et début 2023**
- Plusieurs entreprises ayant licencié 100 % de leurs effectifs avaient levé plus d'**1 milliard de dollars**

---

## 👤 Réalisé Par 

**Hiba Kourda**
- GitHub : [hibakourda2025](https://github.com/hibakourda2025)
- LinkedIn : [hiba kourda](https://www.linkedin.com/in/hibakourda/)

---
