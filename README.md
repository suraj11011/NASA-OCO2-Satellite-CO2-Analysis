# 🛰️ NASA-OCO2-Satellite-Carbon-Analysis

### Global CO₂ Trend Analysis & Inter-Product Validation using NASA OCO-2 Satellite Data

![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-orange)
![NASA](https://img.shields.io/badge/Data-NASA%20OCO--2-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

---

## 📌 Overview

Satellite-based atmospheric CO₂ analysis using NASA OCO-2 spaceborne data. Processed HDF5/NetCDF4 granules to quantify a global +13.6 ppm CO₂ rise (2019–2025) and performs inter-product validation between two NASA retrieval algorithms over India. Built in MATLAB with geospatial filtering and multi-temporal visualization.

---

##Analysis 1 Global XCO₂ Trend (2019–2025)

Processes four OCO-2 Level 2 Lite FP (V11.2) NetCDF4 granules spanning 2019 to 2025. Quality-filtered soundings are gridded at 2° resolution and analyzed across five global regions to quantify the rise in column-averaged CO₂ (XCO₂) over six years.

### Figures

| Figure | Description |
|--------|-------------|
| Fig 1 | Global XCO₂ spatial maps — 4 dates with coastline overlays |
| Fig 2 | Year-over-year difference maps vs 2019 baseline |
| Fig 3 | Statistical summary — mean, trend, regional heatmap, P5–P95 |
| Fig 4 | Global XCO₂ distribution histograms 2019→2025 |

### Results

 Global Daily Snapshots
![Global Daily Snapshots XCO₂ spatial distribution across 4 dates](Images/global-daily-snapshots.png)

Statistical Summary
![Statistical Summary — Mean, trend, and regional heatmaps](Images/statistical-summary.png)

XCO₂ Distribution Analysis
![Global XCO₂ Distribution Histograms showing temporal evolution 2019→2025](Images/global-xc02-distribution.png)

### Key Findings

| Metric | Value |
|--------|-------|
| Global XCO₂ — Dec 2019 | 410.7 ppm |
| Global XCO₂ — Oct 2025 | 424.3 ppm |
| Total increase | +13.6 ppm |
| Linear trend | +2.3 ppm/year |
| Highest regional XCO₂ | East Asia (427.1 ppm in 2025) |

---

Analysis 2 Inter-Product Validation over India

Compares two fundamentally different OCO-2 retrieval algorithms — the full-physics **Lite FP** product and the **IMAP-DOAS** (Iterative Maximum A Posteriori DOAS) Level 2 IDP product — over the Indian subcontinent. Identifies and explains a systematic bias between the two products.

### Figures

| Figure | Description |
|--------|-------------|
| Fig 5 | Side-by-side spatial maps — Lite FP vs IMAP-DOAS over India |
| Fig 6 | XCO₂ distribution comparison — both products overlaid |
| Fig 7 | Statistical comparison table — mean, std, P5, P95, range |

### Results

#### 🔄 Cross-Product Analysis
![Cross-Product Validation Lite FP vs IMAP-DOAS over India](Images/cross-analysis.png)

### Key Findings

| Metric | Lite FP (Dec 2019) | IMAP-DOAS (Oct 2019) | Difference |
|--------|-------------------|----------------------|------------|
| Soundings | 1,067 | 598 | — |
| Mean XCO₂ | 410.08 ppm | 398.65 ppm | −11.43 ppm |
| Std | 0.910 ppm | 4.224 ppm | +3.314 ppm |
| P5 | 408.52 ppm | 390.85 ppm | −17.66 ppm |
| P95 | 411.27 ppm | 404.96 ppm | −6.32 ppm |

> **Note:** The ~11 ppm difference is attributed to three factors:
> seasonal CO₂ variability (~3–4 ppm), algorithmic retrieval
> differences between the two preprocessing approaches, and
> non-coincident orbital sampling (Oct 2 vs Dec 31, 2019).

---

## Dataset

| File | Product | Date | Coverage |
|------|---------|------|----------|
| `oco2_LtCO2_191231_...nc4` | OCO-2 L2 Lite FP V11.2 | Dec 31, 2019 | Global |
| `oco2_LtCO2_211231_...nc4` | OCO-2 L2 Lite FP V11.2 | Dec 31, 2021 | Global |
| `oco2_LtCO2_231231_...nc4` | OCO-2 L2 Lite FP V11.2 | Dec 31, 2023 | Global |
| `oco2_LtCO2_251031_...nc4` | OCO-2 L2 Lite FP V11.2 | Oct 31, 2025 | Global |
| `oco2_L2IDPGL_191002_...h5` | OCO-2 L2 IMAP-DOAS V10r | Oct 02, 2019 | Global |

> Data files not included due to size constraints.
> Download from [NASA GES DISC](https://disc.gsfc.nasa.gov)

---

## Repository Structure

```
├── analysis1_global_co2.m         # Global XCO₂ trend analysis
├── analysis3_cross_validation.m   # Inter-product validation
├── outputs/                       # Generated figures (.png)
└── README.md
```

---

## How to Run

1. Download data files from [NASA GES DISC](https://disc.gsfc.nasa.gov)
2. Place all `.nc4` and `.h5` files in the same folder as the scripts
3. Open MATLAB and navigate to the project folder
4. Run `analysis1_global_co2.m`
5. Run `analysis3_cross_validation.m`

**Requirements:** MATLAB R2019b or later | Mapping Toolbox

---

## Skills Demonstrated

- Satellite remote sensing data processing (HDF5, NetCDF4)
- Geospatial filtering, bounding box extraction and land/ocean masking
- Multi-temporal atmospheric CO₂ trend analysis
- Gridded spatial interpolation from sparse orbital track data
- Inter-product scientific validation methodology
- Statistical analysis and publication-quality visualization in MATLAB

---

## Data Citation

> Crisp, D., et al. (2020). OCO-2 Level 2 Lite FP, V11.2.
> NASA Goddard Earth Sciences Data and Information Services Center (GES DISC).
> DOI: 10.5067/H114N0ZUSPZL
