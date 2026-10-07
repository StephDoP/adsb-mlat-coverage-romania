# Data

| Path | Content | Origin | In the repository |
|---|---|---|---|
| `sites/site_coordinates.xlsx` | Candidate ADS-B sites in three sheets: `VOR & DME` (15 stations, **used by the pipeline**), `Int Aero` (15 airports) and `peeks` (10 highest peaks) | Compiled for the thesis | yes |
| `border/ro_frontiera_poligon.*` | Romanian national border polygon, ESRI shapefile in Stereo 70 (EPSG:3844), attribute `version` = 20211223 | Original download source not recorded in the project files | yes |
| `srtm/` | 59 SRTM 1 arc-second elevation tiles (GeoTIFF, ~1.5 GB) | USGS EarthExplorer | no, download them (below) |
| `processed/dem.mat` | DEM grid built by step 1 (~95 MB) | Derived from SRTM | no, attached to the [latest release](https://github.com/StephDoP/adsb-mlat-coverage-romania/releases/latest); run `download_dem` |
| `processed/border.mat` | Border in geographic degrees (step 2) | Derived from the shapefile | yes |
| `processed/antennas.mat` | Station table (step 5) | Derived from `site_coordinates.xlsx` | yes |
| `processed/los_ranges.mat` | Terrain-limited coverage polygons (step 6) | Derived | yes |

`dem.mat` SHA-256: `b818d3f5d71af1270ec0fe9edb35881b050db17d5369667813c3e5dcb1db5973`.

The processed files are exactly the ones used for the thesis results. Re-running the
pipeline regenerates them identically: steps 1, 2, 5 and 6 reproduce `dem.mat`,
`border.mat`, `antennas.mat` and `los_ranges.mat` value for value (checked with MATLAB
R2024b and R2026b).

## ADS-B station sites

One receiver per Romanian VOR/DME site (`VOR & DME` sheet, read by steps 4 and 5).
The line-of-sight computation (steps 6 and 7) places the antenna 10 m above the listed
site elevation.

| # | Station | Site elevation (ft) | Latitude (°N) | Longitude (°E) |
|---:|---|---:|---:|---:|
| 1 | ARAD | 400 | 46.1841 | 21.1436 |
| 2 | BACAU | 1800 | 46.5109 | 26.8255 |
| 3 | BRASOV | 5900 | 45.5675 | 25.5647 |
| 4 | CLUJ | 1600 | 46.8001 | 23.7873 |
| 5 | CONSTANTA | 300 | 44.2945 | 28.4795 |
| 6 | CRAIOVA | 600 | 44.3186 | 23.9228 |
| 7 | DEVA | 900 | 45.8280 | 22.9689 |
| 8 | FLORESTI | 400 | 44.5008 | 25.7082 |
| 9 | GALATI | 200 | 45.4163 | 27.9277 |
| 10 | ROSIORI | 300 | 44.5925 | 26.5602 |
| 11 | SATU MARE | 500 | 47.7274 | 22.8939 |
| 12 | SUCEAVA | 1300 | 47.6723 | 26.3608 |
| 13 | STREJNIC | 600 | 44.9186 | 25.9770 |
| 14 | TG JIU | 900 | 45.0608 | 23.3341 |
| 15 | TULCEA | 300 | 45.0786 | 28.7094 |

The `Int Aero` and `peeks` sheets hold the two alternative site sets compared in the
thesis; they are only used by the scripts in [`../prototypes`](../prototypes).

## SRTM tiles (only needed to rebuild the DEM)

Step 1 expects the 1 arc-second tiles for latitudes 43 to 48 °N and longitudes 20 to 29 °E,
named as USGS delivers them (`n43_e020_1arc_v3.tif` ... `n48_e029_1arc_v3.tif`). That is
60 tiles minus `n43_e029`, which covers only the Black Sea and does not exist; step 1
fills it with zeros.

1. Sign in to [USGS EarthExplorer](https://earthexplorer.usgs.gov/) (free account).
2. *Search Criteria*: draw or type the box 43° to 49° N, 20° to 30° E.
3. *Data Sets*: Digital Elevation > SRTM > **SRTM 1 Arc-Second Global**.
4. *Results*: download every tile as **GeoTIFF**.
5. Put the 59 `.tif` files in `data/srtm/` and run `src/step1_build_dem.m`.

Dataset: USGS EROS Archive, *Digital Elevation: Shuttle Radar Topography Mission (SRTM)
1 Arc-Second Global*, [doi:10.5066/F7PR7TFT](https://doi.org/10.5066/F7PR7TFT). SRTM data
are in the public domain.

## Variables in the processed files

| File | Variable | Size | Meaning |
|---|---|---|---|
| `dem.mat` | `rotatedZ` | 7202 × 12003 double | Terrain elevation (m); row 1 is 43 °N, column 1 is 20 °E |
| | `lon_grid`, `lat_grid` | 1 × 12003, 1 × 7202 | Grid coordinates (°), step 3 arc-seconds |
| | `mm`, `nn` | scalars | Grid size (12003 columns, 7202 rows) |
| `border.mat` | `S` | struct | Border polygon as returned by `shaperead` (Stereo 70 metres) |
| | `lon`, `lat` | 1 × 33848 | Border in degrees |
| `antennas.mat` | `names` | 15 × 1 cell | Station names |
| | `latDME`, `lonDME` | 15 × 1 | Station coordinates (°) |
| | `altitude_meters` | 15 × 1 | Site elevation (m) |
| `los_ranges.mat` | `memlon`, `memlat` | 1 × 4 cell of 15 × 100 | Coverage polygon of each station (rows) over 100 bearings (columns), one cell per flight level: FL60, FL80, FL100, FL120 |
