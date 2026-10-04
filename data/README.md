# Data sources and local inputs

## NHGIS: U.S. county geography and population

The original NHGIS extract uses population counts for 2010, standardised to 2010 county geography, and the `CW8` table, **Persons by Sex [2] by Race [6*]**. Its context fields include `GISJOIN`, `GEOGYEAR`, `STATE`, `STATEA`, `COUNTY`, and `COUNTYA`. The original spatial input is the 2020 county shapefile.

Obtain these from the [NHGIS Data Finder](https://data2.nhgis.org/main). Free registration is required for download. Select county geography, 2010 population by sex and race, and 2020 county GIS boundaries. Extract naming is account-specific, so rename the tabular file and codebook to the names below, preserving the required `CW8AA2010`–`CW8AL2010` columns.

Place these files in `data/private/`:

```text
nhgis0005_ts_geog2010_county.csv
nhgis0005_ts_geog2010_county_codebook.txt
US_county_2020.shp
US_county_2020.shx
US_county_2020.dbf
US_county_2020.prj
US_county_2020.cpg
```

The shapefile's component files must share the same basename. `prepare_dashboard.R` writes `shape_us_final.rds` in this same local directory; the report also writes `shape_us_clean.rds`. These files are ignored by Git. The original shapefile is about 233 MB and each saved R spatial object about 132 MB, exceeding GitHub's ordinary per-file limit.

[NHGIS terms](https://www.nhgis.org/citation-and-use-nhgis-data) require permission for data redistribution and appropriate citation in reports. This repository distributes the report and code, without NHGIS input data or complete derived spatial datasets.

The original codebook identifies Version 20.0. Its recommended citation is:

Jonathan Schroeder, David Van Riper, Steven Manson, Katherine Knowles, Tracy Kugler, Finn Roberts, and Steven Ruggles. *IPUMS National Historical Geographic Information System: Version 20.0* [dataset]. Minneapolis, MN: IPUMS. 2025. [doi:10.18128/D050.V20.0](https://doi.org/10.18128/D050.V20.0).

## ERA5: Italy temperature

`raw/Italy_daily_2015.nc` through `raw/Italy_daily_2022.nc` are the original local snapshots of [ERA5 post-processed daily statistics on single levels](https://cds.climate.copernicus.eu/datasets/derived-era5-single-levels-daily-statistics?tab=overview), produced by the Copernicus Climate Change Service (C3S) at ECMWF. The request specifies 2-metre temperature, daily mean, hourly sampling, UTC, and the bounding box `[46, 5, 37, 19]` (north, west, south, east). The files contain Kelvin values; the analysis converts them to Celsius and aggregates to ISO weeks.

Contains modified Copernicus Climate Change Service information. The weekly CSV `italy_temperature_weekly.csv` is the original derived output. See the source catalogue for its current citation and [CC BY 4.0 licence](https://creativecommons.org/licenses/by/4.0/). Redistribution of these original snapshots avoids a new retrieval silently changing the input revision. The request blocks remain in the report for reference; no account identifier or API key is included.

## World Mortality Dataset

`world_mortality.csv` is the original local snapshot from the [World Mortality Dataset](https://github.com/akarlinsky/world_mortality). `italy_mortality_weekly.csv` is the original filtered Italy series. They contain aggregate country-level death counts, with no individual records. The repository is distributed under the [MIT licence](licenses/world-mortality-MIT.txt).

Reference: Ariel Karlinsky and Dmitry Kobak (2021). *Tracking excess mortality across countries during the COVID-19 pandemic with the World Mortality Dataset.* eLife 10:e69336. [doi:10.7554/eLife.69336](https://doi.org/10.7554/eLife.69336).
