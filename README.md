# OCO-2 Atmospheric Carbon & Vegetation Analysis
### NASA Orbiting Carbon Observatory-2 | Multi-Scale Remote Sensing Study

---

## Project Overview

This project processes and analyzes NASA's OCO-2 (Orbiting Carbon Observatory-2) satellite data to study:
1. **Global CO₂ trends** from 2019 to 2025 using Level 2 Lite FP data
2. **Solar Induced Fluorescence (SIF)** over Indian agricultural regions in October 2019
3. **Inter-product validation** comparing two different OCO-2 retrieval algorithms

---

## Dataset

| File | Product | Date | Coverage |
|------|---------|------|----------|
| `oco2_LtCO2_191231_...nc4` | OCO-2 L2 Lite FP V11.2 | Dec 31, 2019 | Global |
| `oco2_LtCO2_211231_...nc4` | OCO-2 L2 Lite FP V11.2 | Dec 31, 2021 | Global |
| `oco2_LtCO2_231231_...nc4` | OCO-2 L2 Lite FP V11.2 | Dec 31, 2023 | Global |
| `oco2_LtCO2_251031_...nc4` | OCO-2 L2 Lite FP V11.2 | Oct 31, 2025 | Global |
| `oco2_L2IDPGL_191002_...h5` | OCO-2 L2 IMAP-DOAS V10r | Oct 02, 2019 | Global/India |

**Source:** NASA GES DISC — https://disc.gsfc.nasa.gov

---

## Analysis Scripts

### `oco2_global_co2.m` — Global CO₂ Trend Analysis
- Global XCO₂ spatial maps for 4 dates
- Year-over-year difference maps vs 2019 baseline
- Statistical summary with regional breakdown
- Distribution histograms 2019→2025

### `analysis2_sif_india.m` — SIF Vegetation Analysis over India
- Orbital track SIF maps over India
- Spatially interpolated SIF heatmap
- Regional agricultural analysis (8 states)
- IGBP land cover vs SIF relationship
- SIF 757nm vs 771nm band consistency

### `analysis3_cross_validation.m` — Inter-Product Validation
- Spatial comparison: Lite FP vs IMAP-DOAS
- Distribution comparison over India
- Statistical differences between retrieval algorithms

---

## Key Findings

- Global XCO₂ increased from **410.7 ppm (2019)** to **424.3 ppm (2025)** — a rise of ~13.6 ppm
- Linear trend: **+2.3 ppm/year**, accelerating vs historical rates
- East Asia consistently shows the highest XCO₂ concentrations globally
- October 2019 SIF analysis captures the **Kharif harvest season** over India
- Punjab/Haryana region shows distinct SIF signal consistent with active croplands

---

## Requirements

- MATLAB R2019b or later
- Mapping Toolbox (for shapefile support)
- Data files placed in the same directory as scripts

---

## Skills Demonstrated

- Satellite remote sensing data processing (HDF5, NetCDF4)
- Geospatial filtering, bounding box and land/water masking
- Multi-temporal atmospheric data analysis
- Gridded interpolation from sparse orbital track data
- Statistical summarization and visualization
- Inter-product scientific validation methodology
