# Population maps and the 2022 Italian heatwave

**Authors:** Juan Esteban Londono and Juan Pablo Ariza  
**Course:** Data Visualisation  
**Original report date:** 25 March 2026

An academic R project combining U.S. county population visualisations with an analysis of weekly temperature and mortality in Italy. The first part builds bar charts, thematic maps, and a Shiny dashboard. The second part processes ERA5 daily temperature files, estimates a seasonal mortality baseline, and explores the temperature–mortality relationship.

## Read the final work

Download [the final HTML report](reports/final-report.html) and open it in a browser. It preserves the original self-contained report, including its figures and dashboard screenshots; five machine-specific paths in displayed code or messages are replaced by relative paths. It does not require R or the input datasets. GitHub's file viewer displays HTML source rather than running the report.

![County dashboard](Task_4_ss.png)

## Repository contents

| File or folder | Purpose |
| --- | --- |
| `report.Rmd` | Source corresponding to the original self-contained report |
| `report-interactive.Rmd` | Original alternative with an executable Leaflet map and external HTML assets |
| `app.R` | Interactive county population Shiny app |
| `prepare_dashboard.R` | Builds the dataset required by the app |
| `data/` | Original mortality and climate snapshots used in Part 2 |
| `data/private/` | Local NHGIS inputs and generated spatial objects; excluded from Git |
| `reports/final-report.html` | Original final report |
| `styles.css` | Original report styles |

The two original copies of the interactive R Markdown source were identical and are represented by one file. Temporary R sessions, histories, cached chunk outputs, and redundant NetCDF files are excluded.

## Run locally

Use R with the packages listed in [setup.R](setup.R). In an R session opened at the repository root:

```r
source("setup.R")
```

This command installs missing report and dashboard packages from CRAN. It does not download NHGIS or submit climate-data requests.

1. Obtain the NHGIS inputs described in [data/README.md](data/README.md) and place them in `data/private/`.
2. Render the report:

```r
rmarkdown::render("report.Rmd", output_dir = "reports")
```

3. Prepare and open the county dashboard:

```r
source("prepare_dashboard.R")
shiny::runApp(".")
```

R Markdown requires Pandoc, which is bundled with RStudio. The Leaflet basemap uses an internet connection. All file paths are relative to the repository root.

The supplied NetCDF files are used by default. Download requests from the original report are retained but disabled. To request new climate files, install `ecmwfr` and `keyring`, configure a private `CDS_API_KEY` environment variable, and explicitly set `params = list(download_climate_data = TRUE)` when rendering. Keep that key outside this repository.

The interactive alternative can embed the complete local county dataset in its HTML. Newly generated reports and their assets are ignored by Git; review any such export against the NHGIS terms before redistributing it. The included final report uses static screenshots for the interactive elements.

## Data and interpretation

NHGIS data and derived spatial datasets are not redistributed. Their terms require permission for redistribution, so readers obtain their own extract; the published report retains the original summary tables, plots, and screenshots. See [data/README.md](data/README.md) for sources, citations, licences, and exact input names.

The original analytical choices, estimates, figures, and authorship are preserved. The Italy analysis is descriptive: the seasonal model and bin-scatter relationship do not by themselves identify a causal effect of heat. The original use of 2010 population data with 2020 county boundaries leaves an unmatched historical county.

## Validation

The report was fully rendered with R 4.5.1 using the local licensed inputs, without new climate-data downloads. Dashboard preprocessing reproduced the original 3,108-county spatial dataset exactly; selection, map-click and population-share server tests passed. Regenerated weekly temperature and mortality data match the supplied snapshots, and the summer 2022 excess-death total reproduces approximately 26,783. The published historical report retains its original results and images.

## Possible extensions

- Reconcile historical county boundaries and names before merging population data.
- Evaluate spatial masking and area weighting for the temperature average, which currently uses all grid cells within the requested bounding box.
- Add uncertainty estimates and robustness checks to the mortality baseline, and distinguish temporal association from causal attribution.

These would change the analytical results and are not applied to this archived academic submission.
