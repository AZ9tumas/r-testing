"""
datahandler.py - Export all NIQ-DATASET Excel sheets to clean, importable CSVs.

Reads every sheet from NIQ-DATA (V1.3.5).xlsx and saves each as a
pandas-friendly CSV (like the WorldBank dataset in animint2 — a simple
DataFrame that can be read with read.csv() or pd.read_csv() anywhere).

Output files in ../Output/:
    niq_fav.csv  – FAV sheet: national IQ summary (1 row per country, ~29 cols)
    niq_nat.csv  – NAT sheet: national indicators  (1 row per country, ~889 cols)
    niq_rec.csv  – REC sheet: sample-level records  (1 row per IQ study, 49 cols)
"""

import os
import re
import pandas as pd

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
EXCEL_PATH = os.path.join(SCRIPT_DIR, "NIQ-DATA (V1.3.5).xlsx")
OUTPUT_DIR = os.path.join(SCRIPT_DIR, os.pardir, "Output")


def _clean_colnames(columns):
    """
    Make column names safe for pandas / R:
      - Convert everything to string
      - Strip leading/trailing whitespace
      - Replace newlines with spaces
      - Deduplicate: append _2, _3, … for repeats
    """
    cleaned = []
    for c in columns:
        name = str(c).strip().replace("\n", " ").replace("\r", "")
        cleaned.append(name)

    # Deduplicate
    seen = {}
    deduped = []
    for name in cleaned:
        if name in seen:
            seen[name] += 1
            deduped.append(f"{name}_{seen[name]}")
        else:
            seen[name] = 1
            deduped.append(name)
    return deduped


def _is_valid_iso3(series):
    """Boolean mask: True for rows where value is a 3-letter uppercase code."""
    return series.astype(str).str.match(r"^[A-Z]{3}$", na=False)


# ===== FAV sheet ==========================================================

def export_fav(excel_path: str) -> pd.DataFrame:
    """
    Read the FAV (favorites) sheet.
    Row 0 = group header, Row 1 = column header, rows 2+ = data.
    First two unnamed columns are iso3 and country.
    """
    # Read with the sub-header row (row index 1) as the column names
    df = pd.read_excel(excel_path, sheet_name="FAV", header=None, skiprows=2)

    # Build proper column names from the header row we skipped
    hdr = pd.read_excel(excel_path, sheet_name="FAV", header=None,
                        nrows=2)
    # Row 1 has the real column labels; row 0 has group labels
    col_labels = hdr.iloc[1].tolist()
    col_labels[0] = "iso3"
    col_labels[1] = "country"
    # Prefix "NIQ_" to the core IQ columns for clarity
    for i in range(2, min(14, len(col_labels))):
        val = str(col_labels[i]).strip()
        if val and val != "nan":
            col_labels[i] = f"NIQ_{val}"

    df.columns = _clean_colnames(col_labels[:len(df.columns)])

    # Keep only valid country rows (3-letter ISO codes)
    df = df[_is_valid_iso3(df["iso3"])].copy()
    df["country"] = df["country"].astype(str).str.strip()
    df = df.reset_index(drop=True)
    return df


# ===== NAT sheet ==========================================================

def export_nat(excel_path: str) -> pd.DataFrame:
    """
    Read the full NAT (national) sheet — all 889 columns.
    One row per country, every indicator preserved.
    """
    df = pd.read_excel(excel_path, sheet_name="NAT", header=1)
    df.columns = _clean_colnames(df.columns)

    # The first column is always ISO 3166-1 ALPHA-3
    iso_col = df.columns[0]    # "ISO 3166-1 ALPHA-3"
    df = df[_is_valid_iso3(df[iso_col])].copy()

    # Rename the identifier columns for convenience
    df = df.rename(columns={iso_col: "iso3", df.columns[1]: "country"})
    df["country"] = df["country"].astype(str).str.strip()
    df = df.reset_index(drop=True)
    return df


# ===== REC sheet ==========================================================

def export_rec(excel_path: str) -> pd.DataFrame:
    """
    Read the full REC (records) sheet — all 49 columns.
    One row per IQ-test sample, every field preserved.
    """
    df = pd.read_excel(excel_path, sheet_name="REC", header=1)
    df.columns = _clean_colnames(df.columns)

    iso_col = "ISO 3166-1 ALPHA-3"
    df = df[_is_valid_iso3(df[iso_col])].copy()

    df = df.rename(columns={iso_col: "iso3", "Country name": "country"})
    df["country"] = df["country"].astype(str).str.strip()
    df = df.reset_index(drop=True)
    return df


# ===== IQ trends (analysis-ready) ==========================================

def export_iq_trends(rec: pd.DataFrame) -> pd.DataFrame:
    """
    Build a tidy, analysis-ready table from the REC data with one row per
    IQ-test sample and only the columns needed for plotting / modelling:

        country, iso3, year, IQ, test_type, n_individuals, domain

    Rows with missing IQ or year are dropped.
    """
    col_map = {
        "country":    "country",
        "iso3":       "iso3",
        "Year (meas.)":  "year",
        "IQ (cor.)":     "IQ",
        "Test (type)":   "test_type",
        "N (ind.)":      "n_individuals",
        "Domain":        "domain",
    }
    df = rec[list(col_map.keys())].rename(columns=col_map).copy()
    df["year"] = pd.to_numeric(df["year"], errors="coerce")
    df["IQ"]   = pd.to_numeric(df["IQ"],   errors="coerce")
    df["n_individuals"] = pd.to_numeric(df["n_individuals"], errors="coerce")
    df = df.dropna(subset=["year", "IQ"]).reset_index(drop=True)
    df["year"] = df["year"].astype(int)
    return df


def export_samples(rec: pd.DataFrame, fav: pd.DataFrame) -> pd.DataFrame:
    """
    Enriched sample-level table: iq_trends columns + sample_id, Region,
    population, and national-level IQ (from FAV) for comparative analysis.
    """
    trends = export_iq_trends(rec)

    # Attach the sample ID
    trends.insert(0, "sample_id", rec.loc[trends.index, "ID"])

    # Build a lookup from FAV for region & national IQ
    niq_col = next((c for c in fav.columns if "QNW" in c), None)
    fav_lookup = fav[["iso3"]].copy()
    if niq_col:
        fav_lookup["IQ_national"] = pd.to_numeric(fav[niq_col], errors="coerce")

    trends = trends.merge(fav_lookup, on="iso3", how="left")
    return trends


# ===========================================================================
# Main
# ===========================================================================
if __name__ == "__main__":
    print(f"Reading: {EXCEL_PATH}\n")
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # --- FAV ---
    fav = export_fav(EXCEL_PATH)
    fav_path = os.path.join(OUTPUT_DIR, "niq_fav.csv")
    fav.to_csv(fav_path, index=False)
    print(f"FAV → {fav_path}")
    print(f"     {fav.shape[0]} countries × {fav.shape[1]} columns")
    print(f"     Columns: {fav.columns.tolist()[:10]} ...")

    # --- NAT ---
    nat = export_nat(EXCEL_PATH)
    nat_path = os.path.join(OUTPUT_DIR, "niq_nat.csv")
    nat.to_csv(nat_path, index=False)
    print(f"\nNAT → {nat_path}")
    print(f"     {nat.shape[0]} countries × {nat.shape[1]} columns")
    print(f"     First 15 columns: {nat.columns.tolist()[:15]}")

    # --- REC ---
    rec = export_rec(EXCEL_PATH)
    rec_path = os.path.join(OUTPUT_DIR, "niq_rec.csv")
    rec.to_csv(rec_path, index=False)
    print(f"\nREC → {rec_path}")
    print(f"     {rec.shape[0]} samples × {rec.shape[1]} columns")
    print(f"     Columns: {rec.columns.tolist()}")

    # --- IQ trends (analysis-ready) ---
    trends = export_iq_trends(rec)
    trends_path = os.path.join(OUTPUT_DIR, "niq_iq_trends.csv")
    trends.to_csv(trends_path, index=False)
    print(f"\nIQ trends → {trends_path}")
    print(f"     {trends.shape[0]} samples × {trends.shape[1]} columns")
    print(f"     Columns: {trends.columns.tolist()}")

    # --- Samples (enriched) ---
    samples = export_samples(rec, fav)
    samples_path = os.path.join(OUTPUT_DIR, "niq_samples.csv")
    samples.to_csv(samples_path, index=False)
    print(f"\nSamples → {samples_path}")
    print(f"     {samples.shape[0]} samples × {samples.shape[1]} columns")
    print(f"     Columns: {samples.columns.tolist()}")

    # --- Quick preview ---
    print("\n" + "=" * 60)
    print("Preview: niq_fav.csv (first 5 rows, key columns)")
    print("=" * 60)
    preview_cols = [c for c in fav.columns[:8]]
    print(fav[preview_cols].head().to_string(index=False))

    print("\n" + "=" * 60)
    print("Preview: niq_iq_trends.csv (first 10 rows)")
    print("=" * 60)
    print(trends.head(10).to_string(index=False))

    print("\n" + "=" * 60)
    print("Preview: niq_rec.csv (first 5 rows, key columns)")
    print("=" * 60)
    preview_cols = ["ID", "iso3", "country", "Year (meas.)", "IQ (cor.)",
                    "Test (type)", "N (ind.)"]
    preview_cols = [c for c in preview_cols if c in rec.columns]
    print(rec[preview_cols].head().to_string(index=False))
