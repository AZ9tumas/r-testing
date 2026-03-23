"""
datahandler.py - Transform NIQ-DATASET Excel into a WorldBank-like DataFrame.

Reads the NIQ-DATA (V1.3.5).xlsx Excel file and produces a tidy, long-format
CSV structured like the WorldBank dataset from animint2 in R:

  WorldBank columns:  country, iso2c, iso3c, year, region, population,
                      fertility.rate, life.expectancy, GDP.per.capita.Current.USD,
                      latitude, longitude, income, lending, ...

  Our IQ analogue:    country, iso3c, year, region, population,
                      fertility.rate, GDP.per.capita, HDI, IQ,
                      latitude, longitude

One row per country per year (panel data).  Output: ../Output/niq_data.csv
"""

import re
import os
import pandas as pd

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
EXCEL_PATH = os.path.join(SCRIPT_DIR, "NIQ-DATA (V1.3.5).xlsx")
OUTPUT_DIR = os.path.join(SCRIPT_DIR, os.pardir, "Output")
OUTPUT_CSV = os.path.join(OUTPUT_DIR, "niq_data.csv")

# ---------------------------------------------------------------------------
# ISO-3 → World Bank region mapping
# ---------------------------------------------------------------------------
REGION_MAP = {
    # East Asia & Pacific
    "AUS": "East Asia & Pacific", "BRN": "East Asia & Pacific",
    "KHM": "East Asia & Pacific", "CHN": "East Asia & Pacific",
    "FJI": "East Asia & Pacific", "HKG": "East Asia & Pacific",
    "IDN": "East Asia & Pacific", "JPN": "East Asia & Pacific",
    "KIR": "East Asia & Pacific", "PRK": "East Asia & Pacific",
    "KOR": "East Asia & Pacific", "LAO": "East Asia & Pacific",
    "MAC": "East Asia & Pacific", "MYS": "East Asia & Pacific",
    "MHL": "East Asia & Pacific", "FSM": "East Asia & Pacific",
    "MNG": "East Asia & Pacific", "MMR": "East Asia & Pacific",
    "NRU": "East Asia & Pacific", "NZL": "East Asia & Pacific",
    "PLW": "East Asia & Pacific", "PNG": "East Asia & Pacific",
    "PHL": "East Asia & Pacific", "WSM": "East Asia & Pacific",
    "SGP": "East Asia & Pacific", "SLB": "East Asia & Pacific",
    "TWN": "East Asia & Pacific", "THA": "East Asia & Pacific",
    "TLS": "East Asia & Pacific", "TON": "East Asia & Pacific",
    "TUV": "East Asia & Pacific", "VUT": "East Asia & Pacific",
    "VNM": "East Asia & Pacific",
    # Europe & Central Asia
    "ALB": "Europe & Central Asia", "AND": "Europe & Central Asia",
    "ARM": "Europe & Central Asia", "AUT": "Europe & Central Asia",
    "AZE": "Europe & Central Asia", "BLR": "Europe & Central Asia",
    "BEL": "Europe & Central Asia", "BIH": "Europe & Central Asia",
    "BGR": "Europe & Central Asia", "HRV": "Europe & Central Asia",
    "CYP": "Europe & Central Asia", "CZE": "Europe & Central Asia",
    "DNK": "Europe & Central Asia", "EST": "Europe & Central Asia",
    "FIN": "Europe & Central Asia", "FRA": "Europe & Central Asia",
    "GEO": "Europe & Central Asia", "DEU": "Europe & Central Asia",
    "GRC": "Europe & Central Asia", "HUN": "Europe & Central Asia",
    "ISL": "Europe & Central Asia", "IRL": "Europe & Central Asia",
    "ITA": "Europe & Central Asia", "KAZ": "Europe & Central Asia",
    "XKX": "Europe & Central Asia", "KGZ": "Europe & Central Asia",
    "LVA": "Europe & Central Asia", "LIE": "Europe & Central Asia",
    "LTU": "Europe & Central Asia", "LUX": "Europe & Central Asia",
    "MKD": "Europe & Central Asia", "MLT": "Europe & Central Asia",
    "MDA": "Europe & Central Asia", "MCO": "Europe & Central Asia",
    "MNE": "Europe & Central Asia", "NLD": "Europe & Central Asia",
    "NOR": "Europe & Central Asia", "POL": "Europe & Central Asia",
    "PRT": "Europe & Central Asia", "ROU": "Europe & Central Asia",
    "RUS": "Europe & Central Asia", "SMR": "Europe & Central Asia",
    "SRB": "Europe & Central Asia", "SVK": "Europe & Central Asia",
    "SVN": "Europe & Central Asia", "ESP": "Europe & Central Asia",
    "SWE": "Europe & Central Asia", "CHE": "Europe & Central Asia",
    "TJK": "Europe & Central Asia", "TUR": "Europe & Central Asia",
    "TKM": "Europe & Central Asia", "UKR": "Europe & Central Asia",
    "GBR": "Europe & Central Asia", "UZB": "Europe & Central Asia",
    # Latin America & Caribbean
    "ARG": "Latin America & Caribbean", "BHS": "Latin America & Caribbean",
    "BRB": "Latin America & Caribbean", "BLZ": "Latin America & Caribbean",
    "BOL": "Latin America & Caribbean", "BRA": "Latin America & Caribbean",
    "CHL": "Latin America & Caribbean", "COL": "Latin America & Caribbean",
    "CRI": "Latin America & Caribbean", "CUB": "Latin America & Caribbean",
    "DMA": "Latin America & Caribbean", "DOM": "Latin America & Caribbean",
    "ECU": "Latin America & Caribbean", "SLV": "Latin America & Caribbean",
    "GRD": "Latin America & Caribbean", "GTM": "Latin America & Caribbean",
    "GUY": "Latin America & Caribbean", "HTI": "Latin America & Caribbean",
    "HND": "Latin America & Caribbean", "JAM": "Latin America & Caribbean",
    "MEX": "Latin America & Caribbean", "NIC": "Latin America & Caribbean",
    "PAN": "Latin America & Caribbean", "PRY": "Latin America & Caribbean",
    "PER": "Latin America & Caribbean", "PRI": "Latin America & Caribbean",
    "KNA": "Latin America & Caribbean", "LCA": "Latin America & Caribbean",
    "VCT": "Latin America & Caribbean", "SUR": "Latin America & Caribbean",
    "TTO": "Latin America & Caribbean", "URY": "Latin America & Caribbean",
    "VEN": "Latin America & Caribbean", "ATG": "Latin America & Caribbean",
    "BMU": "Latin America & Caribbean", "CYM": "Latin America & Caribbean",
    # Middle East & North Africa
    "DZA": "Middle East & North Africa", "BHR": "Middle East & North Africa",
    "EGY": "Middle East & North Africa", "IRN": "Middle East & North Africa",
    "IRQ": "Middle East & North Africa", "ISR": "Middle East & North Africa",
    "JOR": "Middle East & North Africa", "KWT": "Middle East & North Africa",
    "LBN": "Middle East & North Africa", "LBY": "Middle East & North Africa",
    "MAR": "Middle East & North Africa", "OMN": "Middle East & North Africa",
    "PSE": "Middle East & North Africa", "QAT": "Middle East & North Africa",
    "SAU": "Middle East & North Africa", "SYR": "Middle East & North Africa",
    "TUN": "Middle East & North Africa", "ARE": "Middle East & North Africa",
    "YEM": "Middle East & North Africa",
    # North America
    "CAN": "North America", "USA": "North America",
    # South Asia
    "AFG": "South Asia", "BGD": "South Asia", "BTN": "South Asia",
    "IND": "South Asia", "MDV": "South Asia", "NPL": "South Asia",
    "PAK": "South Asia", "LKA": "South Asia",
    # Sub-Saharan Africa
    "AGO": "Sub-Saharan Africa", "BEN": "Sub-Saharan Africa",
    "BWA": "Sub-Saharan Africa", "BFA": "Sub-Saharan Africa",
    "BDI": "Sub-Saharan Africa", "CPV": "Sub-Saharan Africa",
    "CMR": "Sub-Saharan Africa", "TCD": "Sub-Saharan Africa",
    "COM": "Sub-Saharan Africa", "COG": "Sub-Saharan Africa",
    "COD": "Sub-Saharan Africa", "CIV": "Sub-Saharan Africa",
    "DJI": "Sub-Saharan Africa", "GNQ": "Sub-Saharan Africa",
    "ERI": "Sub-Saharan Africa", "SWZ": "Sub-Saharan Africa",
    "ETH": "Sub-Saharan Africa", "GAB": "Sub-Saharan Africa",
    "GMB": "Sub-Saharan Africa", "GHA": "Sub-Saharan Africa",
    "GIN": "Sub-Saharan Africa", "GNB": "Sub-Saharan Africa",
    "KEN": "Sub-Saharan Africa", "LSO": "Sub-Saharan Africa",
    "LBR": "Sub-Saharan Africa", "MDG": "Sub-Saharan Africa",
    "MWI": "Sub-Saharan Africa", "MLI": "Sub-Saharan Africa",
    "MRT": "Sub-Saharan Africa", "MUS": "Sub-Saharan Africa",
    "MOZ": "Sub-Saharan Africa", "NAM": "Sub-Saharan Africa",
    "NER": "Sub-Saharan Africa", "NGA": "Sub-Saharan Africa",
    "RWA": "Sub-Saharan Africa", "STP": "Sub-Saharan Africa",
    "SEN": "Sub-Saharan Africa", "SYC": "Sub-Saharan Africa",
    "SLE": "Sub-Saharan Africa", "SOM": "Sub-Saharan Africa",
    "ZAF": "Sub-Saharan Africa", "SSD": "Sub-Saharan Africa",
    "SDN": "Sub-Saharan Africa", "TZA": "Sub-Saharan Africa",
    "TGO": "Sub-Saharan Africa", "UGA": "Sub-Saharan Africa",
    "ZMB": "Sub-Saharan Africa", "ZWE": "Sub-Saharan Africa",
    "CAF": "Sub-Saharan Africa",
}


# ---------------------------------------------------------------------------
# Helpers – melt wide year-columns into long format
# ---------------------------------------------------------------------------

def _melt_year_columns(nat, prefix, value_name, year_regex=None):
    """
    Pick columns from *nat* whose names start with *prefix* and contain a
    year in parentheses, e.g. "Total pop. (1960AD)" or "HDI (2000)".
    Returns a long DataFrame with columns: iso3c, year, <value_name>.
    """
    if year_regex is None:
        year_regex = re.compile(r"\((\d{4})")

    id_col = "ISO 3166-1 ALPHA-3"
    cols = [c for c in nat.columns if isinstance(c, str) and c.startswith(prefix)]
    if not cols:
        return pd.DataFrame(columns=["iso3c", "year", value_name])

    melted = nat[[id_col] + cols].melt(id_vars=id_col, var_name="_col",
                                        value_name=value_name)
    melted["year"] = melted["_col"].str.extract(year_regex, expand=False)
    melted = melted.dropna(subset=["year"])
    melted["year"] = melted["year"].astype(int)
    melted = melted.rename(columns={id_col: "iso3c"}).drop(columns="_col")
    melted[value_name] = pd.to_numeric(melted[value_name], errors="coerce")
    return melted


def build_worldbank_style(excel_path: str) -> pd.DataFrame:
    """
    Build a tidy, long-format DataFrame from the NIQ Excel file,
    structured like the WorldBank dataset in animint2.

    One row per country per year.  Columns mirror WorldBank:
        country, iso3c, year, region, population,
        fertility.rate, GDP.per.capita, HDI, IQ, latitude, longitude
    """
    # --- Load sheets ---
    nat = pd.read_excel(excel_path, sheet_name="NAT", header=1)
    nat = nat[nat["ISO 3166-1 ALPHA-3"].str.match(r"^[A-Z]{3}$", na=False)].copy()

    fav = pd.read_excel(excel_path, sheet_name="FAV", header=None, skiprows=2)
    fav_cols = [
        "iso3c", "country", "NIQ_UW", "NIQ_NW", "NIQ_QNW", "NIQ_SAS",
        "NIQ_QNW_SAS", "NIQ_QNW_SAS_GEO", "NIQ_LV02", "NIQ_LV02_GEO",
        "NIQ_LV12", "NIQ_LV12_GEO", "IQ_LV12_minus_NIQ", "NIQ_R",
    ]
    fav = fav.iloc[:, :len(fav_cols)]
    fav.columns = fav_cols
    fav = fav[fav["iso3c"].str.match(r"^[A-Z]{3}$", na=False)].copy()

    # --- Melt each time-varying indicator from wide→long ---
    pop  = _melt_year_columns(nat, "Total pop. (", "population")
    gdp  = _melt_year_columns(nat, "GDP/C (",      "GDP.per.capita")
    fert = _melt_year_columns(nat, "Total Fertility Rate (", "fertility.rate")
    hdi  = _melt_year_columns(nat, "HDI (",         "HDI")

    # --- Merge all indicators into one panel ---
    panel = pop.copy()
    for indicator in [gdp, fert, hdi]:
        panel = panel.merge(indicator, on=["iso3c", "year"], how="outer")

    # --- Country name from NAT ---
    country_map = (
        nat.set_index("ISO 3166-1 ALPHA-3")["Country name"]
        .str.strip().to_dict()
    )
    panel["country"] = panel["iso3c"].map(country_map)

    # --- Region ---
    panel["region"] = panel["iso3c"].map(REGION_MAP).fillna("Other")

    # --- National IQ (time-invariant best estimate: QNW+SAS+GEO) ---
    iq_map = fav.set_index("iso3c")["NIQ_QNW_SAS_GEO"].to_dict()
    panel["IQ"] = panel["iso3c"].map(iq_map)
    panel["IQ"] = pd.to_numeric(panel["IQ"], errors="coerce")

    # --- Latitude / longitude from NAT ---
    if "Mean latitude" in nat.columns and "Mean longitude" in nat.columns:
        lat_map = nat.set_index("ISO 3166-1 ALPHA-3")["Mean latitude"].to_dict()
        lon_map = nat.set_index("ISO 3166-1 ALPHA-3")["Mean longitude"].to_dict()
        panel["latitude"]  = pd.to_numeric(panel["iso3c"].map(lat_map), errors="coerce")
        panel["longitude"] = pd.to_numeric(panel["iso3c"].map(lon_map), errors="coerce")

    # --- Reorder columns to match WorldBank convention ---
    # Filter to modern era (WorldBank covers 1960–2012; we keep 1960–2017
    # since fertility/HDI data extends to 2017)
    panel = panel[(panel["year"] >= 1960) & (panel["year"] <= 2017)]

    col_order = ["country", "iso3c", "year", "region", "population",
                 "fertility.rate", "GDP.per.capita", "HDI", "IQ",
                 "latitude", "longitude"]
    col_order = [c for c in col_order if c in panel.columns]
    panel = panel[col_order].sort_values(["country", "year"]).reset_index(drop=True)

    return panel


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    print(f"Reading: {EXCEL_PATH}")
    panel = build_worldbank_style(EXCEL_PATH)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    panel.to_csv(OUTPUT_CSV, index=False)
    print(f"Saved → {OUTPUT_CSV}  ({len(panel)} rows)")

    print(f"\n--- Summary ---")
    print(f"  Countries:  {panel['iso3c'].nunique()}")
    print(f"  Year range: {panel['year'].min()} – {panel['year'].max()}")
    print(f"  Regions:    {sorted(panel['region'].unique())}")
    print(f"  Columns:    {panel.columns.tolist()}")
    print(f"\nFirst 10 rows:")
    print(panel.head(10).to_string(index=False))
